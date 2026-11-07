-- Extra Life / Tiltify event giveaway rules, version 2: optional amount-weighted donor tickets.
-- Loaded by migration 20261107150000 after version 1, and re-applied (in file order) after db:schema:load by
-- lib/tasks/extra_life_sql.rake. Only extra_life_pool changes; every other v1 function is unchanged.
--
-- extra_life_events.donor_tickets_per_dollar NULL or 0: flat rule, one donor ticket per account (v1 behaviour).
-- A positive value N: an account with an active donor source gets floor(N * sum of its qualifying donation amounts)
-- donor tickets, at least 1. Qualifying is exactly extra_life_donor_support: completed, resolved to the account, in the
-- event's campaign, completed in [stream_start_at, cutoff), not the broadcaster. The cutoff is the giveaway's pending
-- (or finalized) draw attempt's cutoff, so the amounts are frozen with entry. Chat stays one ticket. Exclusions are
-- unchanged (weight 0 with a reason). Finalized draws keep their stored snapshot and are never recomputed.
CREATE OR REPLACE FUNCTION extra_life_pool(p_giveaway_id bigint)
RETURNS TABLE (twitch_user_id varchar, login varchar, chat_tickets integer, donor_tickets integer,
               weight integer, excluded_reason varchar)
LANGUAGE sql STABLE AS $$
  WITH g AS (
    SELECT gw.id, gw.extra_life_event_id, e.broadcaster_twitch_id, e.tiltify_campaign_id, e.stream_start_at,
           COALESCE(e.donor_tickets_per_dollar, 0) AS per_dollar,
           (SELECT a.cutoff_at FROM giveaway_draw_attempts a
             WHERE a.giveaway_id = gw.id AND a.status IN ('pending', 'finalized')
             ORDER BY a.id DESC LIMIT 1) AS cutoff
    FROM giveaways gw JOIN extra_life_events e ON e.id = gw.extra_life_event_id
    WHERE gw.id = p_giveaway_id
  ), src AS (
    SELECT t.twitch_user_id,
           (COUNT(*) FILTER (WHERE t.source = 'chat'))::integer AS chat,
           (COUNT(*) FILTER (WHERE t.source = 'donor'))::integer AS donor
    FROM giveaway_ticket_sources t JOIN g ON t.giveaway_id = g.id
    WHERE t.active
    GROUP BY t.twitch_user_id
  ), amounts AS (
    SELECT d.resolved_twitch_user_id AS twitch_user_id, SUM(COALESCE(d.amount_value, 0)) AS total
    FROM g
    JOIN external_donations d ON d.provider = 'tiltify' AND d.campaign_id = g.tiltify_campaign_id
    WHERE g.per_dollar > 0
      AND d.resolved_twitch_user_id IS NOT NULL
      AND d.provider_status = 'completed'
      AND d.completed_at >= g.stream_start_at
      AND (g.cutoff IS NULL OR d.completed_at < g.cutoff)
      AND d.resolved_twitch_user_id <> g.broadcaster_twitch_id
    GROUP BY d.resolved_twitch_user_id
  ), x AS (
    SELECT src.twitch_user_id, src.chat,
           CASE WHEN src.donor > 0 AND g.per_dollar > 0
                THEN GREATEST(1, FLOOR(g.per_dollar * COALESCE(am.total, 0)))::integer
                ELSE src.donor END AS donor,
           a.login AS account_login,
           CASE
             WHEN src.twitch_user_id = g.broadcaster_twitch_id THEN 'broadcaster'
             WHEN EXISTS (SELECT 1 FROM giveaway_awards aw
                           WHERE aw.extra_life_event_id = g.extra_life_event_id
                             AND aw.twitch_user_id = src.twitch_user_id
                             AND aw.giveaway_id <> g.id) THEN 'event_winner'
           END AS reason
    FROM src CROSS JOIN g
    JOIN twitch_accounts a ON a.twitch_user_id = src.twitch_user_id
    LEFT JOIN amounts am ON am.twitch_user_id = src.twitch_user_id
  )
  SELECT x.twitch_user_id, x.account_login, x.chat, x.donor,
         CASE WHEN x.reason IS NULL THEN x.chat + x.donor ELSE 0 END,
         x.reason::varchar
  FROM x
  ORDER BY x.twitch_user_id
$$;
