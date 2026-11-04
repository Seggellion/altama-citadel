-- Extra Life / Tiltify event giveaway rules (version 1). Single authority used by the Python bot (entry, odds,
-- drawing) and Rails (preview, manual assignment). Loaded by migration 20261104010000 and re-applied after
-- db:schema:load by lib/tasks/extra_life_sql.rake. All timestamps are UTC `timestamp without time zone`.
-- A later version must be a new file plus a new migration; never edit this file after release.

-- An award's event must be its giveaway's event. schema.rb dumps this composite FK as a plain one, so it is
-- (re)created here, idempotently, for both migrated and schema-loaded databases.
DO $$
BEGIN
  ALTER TABLE giveaway_awards DROP CONSTRAINT IF EXISTS fk_giveaway_awards_giveaway_event;
  ALTER TABLE giveaway_awards ADD CONSTRAINT fk_giveaway_awards_giveaway_event
    FOREIGN KEY (giveaway_id, extra_life_event_id) REFERENCES giveaways (id, extra_life_event_id);
END;
$$;

-- Accounts holding at least one qualifying donation for a giveaway: completed (not pending/missing/refunded),
-- resolved to a Twitch account, in the event's campaign, completed in [stream_start_at, cutoff), not the broadcaster.
-- p_cutoff NULL means "no cutoff yet" (open giveaway).
CREATE OR REPLACE FUNCTION extra_life_donor_support(p_giveaway_id bigint, p_cutoff timestamp)
RETURNS TABLE (twitch_user_id varchar)
LANGUAGE sql STABLE AS $$
  SELECT DISTINCT d.resolved_twitch_user_id
  FROM giveaways g
  JOIN extra_life_events e ON e.id = g.extra_life_event_id
  JOIN external_donations d
    ON d.provider = 'tiltify' AND d.campaign_id = e.tiltify_campaign_id
  WHERE g.id = p_giveaway_id
    AND d.resolved_twitch_user_id IS NOT NULL
    AND d.provider_status = 'completed'
    AND d.completed_at >= e.stream_start_at
    AND (p_cutoff IS NULL OR d.completed_at < p_cutoff)
    AND d.resolved_twitch_user_id <> e.broadcaster_twitch_id
$$;

-- Bring donor ticket sources of every undrawn giveaway in the event in line with the donation ledger.
-- Finalized giveaways are never touched (finality). Takes the event row lock, which also serialises with draw
-- finalisation and admin edits. Returns the number of source rows changed.
CREATE OR REPLACE FUNCTION extra_life_refresh_donor_sources(p_event_id bigint)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
  g record;
  n integer;
  changed integer := 0;
  ts timestamp := (now() AT TIME ZONE 'UTC');
BEGIN
  PERFORM 1 FROM extra_life_events WHERE id = p_event_id FOR UPDATE;
  FOR g IN
    SELECT gw.id,
           (SELECT a.cutoff_at FROM giveaway_draw_attempts a
             WHERE a.giveaway_id = gw.id AND a.status = 'pending') AS cutoff
    FROM giveaways gw
    WHERE gw.extra_life_event_id = p_event_id
      AND gw.entry_state IN ('open', 'frozen')
      AND gw.winner IS NULL
      AND NOT EXISTS (SELECT 1 FROM giveaway_draw_attempts f WHERE f.giveaway_id = gw.id AND f.status = 'finalized')
    ORDER BY gw.id
  LOOP
    INSERT INTO giveaway_ticket_sources AS t
      (giveaway_id, twitch_user_id, source, active, granted_at, created_at, updated_at)
    SELECT g.id, s.twitch_user_id, 'donor', true, ts, ts, ts
    FROM extra_life_donor_support(g.id, g.cutoff) s
    ON CONFLICT (giveaway_id, twitch_user_id, source) DO UPDATE
      SET active = true, revoked_at = NULL, revoke_reason = NULL, updated_at = EXCLUDED.updated_at
      WHERE t.active = false;
    GET DIAGNOSTICS n = ROW_COUNT;
    changed := changed + n;

    UPDATE giveaway_ticket_sources t
       SET active = false, revoked_at = ts, revoke_reason = 'no_qualifying_donation', updated_at = ts
     WHERE t.giveaway_id = g.id AND t.source = 'donor' AND t.active
       AND NOT EXISTS (SELECT 1 FROM extra_life_donor_support(g.id, g.cutoff) s
                        WHERE s.twitch_user_id = t.twitch_user_id);
    GET DIAGNOSTICS n = ROW_COUNT;
    changed := changed + n;
  END LOOP;
  RETURN changed;
END;
$$;

-- The pool for one giveaway from its active ticket sources: one ticket per active source (chat, donor), so at most
-- two. Excluded rows are returned with weight 0 and a reason: the exact broadcaster id, or an account that already
-- holds an award in another giveaway of the same event. Wins outside the event do not exclude.
CREATE OR REPLACE FUNCTION extra_life_pool(p_giveaway_id bigint)
RETURNS TABLE (twitch_user_id varchar, login varchar, chat_tickets integer, donor_tickets integer,
               weight integer, excluded_reason varchar)
LANGUAGE sql STABLE AS $$
  WITH g AS (
    SELECT gw.id, gw.extra_life_event_id, e.broadcaster_twitch_id
    FROM giveaways gw JOIN extra_life_events e ON e.id = gw.extra_life_event_id
    WHERE gw.id = p_giveaway_id
  ), src AS (
    SELECT t.twitch_user_id,
           (COUNT(*) FILTER (WHERE t.source = 'chat'))::integer AS chat,
           (COUNT(*) FILTER (WHERE t.source = 'donor'))::integer AS donor
    FROM giveaway_ticket_sources t JOIN g ON t.giveaway_id = g.id
    WHERE t.active
    GROUP BY t.twitch_user_id
  ), x AS (
    SELECT src.*, a.login AS account_login,
           CASE
             WHEN src.twitch_user_id = g.broadcaster_twitch_id THEN 'broadcaster'
             WHEN EXISTS (SELECT 1 FROM giveaway_awards aw
                           WHERE aw.extra_life_event_id = g.extra_life_event_id
                             AND aw.twitch_user_id = src.twitch_user_id
                             AND aw.giveaway_id <> g.id) THEN 'event_winner'
           END AS reason
    FROM src CROSS JOIN g JOIN twitch_accounts a ON a.twitch_user_id = src.twitch_user_id
  )
  SELECT x.twitch_user_id, x.account_login, x.chat, x.donor,
         CASE WHEN x.reason IS NULL THEN x.chat + x.donor ELSE 0 END,
         x.reason::varchar
  FROM x
  ORDER BY x.twitch_user_id
$$;

-- Conditions that must block a draw with cutoff p_cutoff (requirement R13). Empty result = no blocker.
CREATE OR REPLACE FUNCTION extra_life_draw_blockers(p_giveaway_id bigint, p_cutoff timestamp)
RETURNS TABLE (code varchar, count integer)
LANGUAGE sql STABLE AS $$
  WITH g AS (
    SELECT gw.id, e.*
    FROM giveaways gw JOIN extra_life_events e ON e.id = gw.extra_life_event_id
    WHERE gw.id = p_giveaway_id
  ), d AS (
    SELECT dn.* FROM external_donations dn JOIN g ON dn.provider = 'tiltify' AND dn.campaign_id = g.tiltify_campaign_id
    WHERE dn.completed_at >= g.stream_start_at AND dn.completed_at < p_cutoff
  )
  SELECT 'event_disabled'::varchar, 1 FROM g WHERE NOT g.enabled
  UNION ALL
  SELECT 'campaign_not_configured', 1 FROM g WHERE g.tiltify_campaign_id IS NULL
  UNION ALL
  SELECT 'before_stream_start', 1 FROM g WHERE p_cutoff <= g.stream_start_at
  UNION ALL
  SELECT 'donation_sync_not_complete_through_cutoff', 1 FROM g
   WHERE g.last_complete_sync_at IS NULL OR g.last_complete_sync_at < p_cutoff
  UNION ALL
  SELECT 'twitch_verification_pending', COUNT(*)::integer FROM d
   WHERE d.manual_twitch_user_id IS NULL AND d.provider_status = 'completed'
     AND d.match_outcome IN ('UNPROCESSED', 'PENDING_VERIFICATION')
  HAVING COUNT(*) > 0
  UNION ALL
  SELECT 'missing_donation_status_unconfirmed', COUNT(*)::integer FROM d
   WHERE d.provider_status = 'missing' AND d.resolved_twitch_user_id IS NOT NULL
     AND NOT EXISTS (SELECT 1 FROM d d2 WHERE d2.resolved_twitch_user_id = d.resolved_twitch_user_id
                                          AND d2.provider_status = 'completed')
  HAVING COUNT(*) > 0
$$;

-- Final, non-blocking unresolved donations inside [stream_start_at, p_cutoff), by outcome (requirement R14).
CREATE OR REPLACE FUNCTION extra_life_unresolved_counts(p_giveaway_id bigint, p_cutoff timestamp)
RETURNS TABLE (outcome varchar, count integer)
LANGUAGE sql STABLE AS $$
  SELECT dn.match_outcome, COUNT(*)::integer
  FROM giveaways gw
  JOIN extra_life_events e ON e.id = gw.extra_life_event_id
  JOIN external_donations dn ON dn.provider = 'tiltify' AND dn.campaign_id = e.tiltify_campaign_id
  WHERE gw.id = p_giveaway_id
    AND dn.completed_at >= e.stream_start_at AND (p_cutoff IS NULL OR dn.completed_at < p_cutoff)
    AND dn.provider_status = 'completed' AND dn.resolved_twitch_user_id IS NULL
    AND dn.match_outcome NOT IN ('UNPROCESSED', 'PENDING_VERIFICATION')
  GROUP BY dn.match_outcome
  ORDER BY dn.match_outcome
$$;
