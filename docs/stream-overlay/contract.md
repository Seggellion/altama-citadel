# Stream overlay data contract (v1)

Shared by **altama-citadel** (Rails, owns the schema and every write) and **altama_sys** (bot, read-only).
Keep the copies in both repos identical.

## Tables (migration `20261107040000_create_stream_overlay_tables`)

| Table | Purpose | Written by | Read by |
| --- | --- | --- | --- |
| `stream_wallet_sessions` | one row per wallet session; `starting_balance_auec` fixed at Start, `current_balance_auec` latest; `status` `active`/`ended`; partial unique index allows one `active` row per bot | Rails admin | Rails |
| `stream_wallet_entries` | append-only audit of each entered balance; `(session, idempotency_key)` unique | Rails admin | Rails |
| `fuelling_accidents` | append-only; `occurred_at` (UTC), `occurred_on` (local date in `time_zone`, default `America/Vancouver`), `voided_at` for undo | Rails admin | Rails, **bot** |
| `stream_overlays` | one per bot: SHA-256 `token_digest` of the OBS URL token, `enabled`, `accident_caption` | Rails admin | Rails |

Money is `bigint` whole aUEC, `0..999,999,999,999`. Net = `current − starting`, computed, never stored.

## Day count (the only cross-app rule)

"Days since the most recent fuelling accident" = calendar-day difference in the accident's time zone. Accident today
→ 0, yesterday → 1, regardless of hours elapsed or clock changes. PostgreSQL computes it for both apps:

```sql
SELECT a.id, ((COALESCE(CAST(:as_of AS timestamptz), now()) AT TIME ZONE a.time_zone)::date - a.occurred_on) AS days
FROM fuelling_accidents a JOIN bots b ON b.id = a.bot_id
WHERE LOWER(b.channel) = LOWER(:channel) AND a.voided_at IS NULL
ORDER BY a.occurred_at DESC, a.id DESC LIMIT 1
```

- Rails: `FuellingAccident::CURRENT_SQL` (`$1`, `$2`). Bot: `stream/accident.py` `CURRENT_SQL` (`%s`, `%s`).
- `as_of` is NULL in production (database `now()`); tests pass explicit UTC instants. Both test suites use the same
  instants (summer midnight; the 2026-03-08 clock change) and expect the same values.
- No row → "no accident on record" (never 0).

## Public overlay JSON (`GET /overlay/:token.json`)

```json
{ "v": 1,
  "wallet":   { "state": "active", "net_auec": -55000 },
  "accident": { "state": "recorded", "days": 4, "caption": "Days since last fuelling accident" },
  "generated_at": "2026-11-08T18:00:00Z" }
```

`wallet.state` ∈ `active` (with `net_auec`), `not_started`, `ended` (no number). `accident.state` ∈ `recorded`
(with `days`), `none`. Nothing else: no balances, ids, names, accident timestamps or tokens. Bad, rotated or disabled
token → empty 404. Errors → `503 {"v":1,"error":"unavailable"}`.

## Bot replies (`!accident`, aliases `!Accident`, `!ACCIDENT`, 15 s per-channel cooldown)

| State | Reply |
| --- | --- |
| 0 | `0 days since the last fuelling accident. It happened today.` |
| 1 | `It has been 1 day since the last fuelling accident.` |
| n | `It has been n days since the last fuelling accident.` |
| none | `No fuelling accidents on record.` |
| DB error / table missing | `The accident board is offline right now.` |
