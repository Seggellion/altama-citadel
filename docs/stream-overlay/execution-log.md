# Stream overlay execution log

Playbook: ALTAMA_STREAM_OVERLAY_SIX_HOUR_PLAYBOOK.md (owner-supplied). Discovery: ALTAMA_STREAM_OVERLAY_DISCOVERY_REPORT.md.
T0 = 2026-11-07 03:26 UTC (cloud session; times are the container clock).

## Environment

- Work done in a cloud container against GitHub `main`, not the owner's WSL checkouts (not reachable from here).
  Before release, check the WSL trees for unpushed work: `git status` / `git log origin/main..` in both.
- Rails `Seggellion/altama-citadel` branch `claude/project-thread-vlpl1s` from `main@d90de16`.
- Bot `Seggellion/altama_sys` branch `claude/project-thread-vlpl1s` from `main@9f0fac5`.
- Local PostgreSQL 16 (throwaway), Ruby 3.3.6 with the Gemfile Ruby pin edited locally only (never committed),
  Python 3.13 venv with twitchio 2.7.0. Test DB `altama_giveaway_test` rebuilt from the branch's `db/schema.rb`.

## Decisions

| ID | Answer | Source |
| --- | --- | --- |
| D-01 | Days since last accident | Owner, decision card 2026-11-07 03:00 UTC |
| D-02 | Calendar day in America/Vancouver, today = 0 (implemented as default) | Asked 03:27 UTC, awaiting |
| D-07 | Rotatable token URL, SHA-256 digest stored (implemented as default) | Asked 03:27 UTC, awaiting |
| Production GO | **Not given.** Nothing deployed. | Asked 03:27 UTC, awaiting |
| D-03/04/05/06/08/09/10/11/12 | Report defaults | Playbook |
| D-13 `!version` bug | Deferred, not touched | Playbook |

## Milestones

| M | Result | Evidence |
| --- | --- | --- |
| M0 | PASS | Both repos clean at discovery SHAs; branches created; baseline from discovery (Rails 44/228/0/0, bot 86 passed) |
| M1 | PASS | Migration `20261107040000` (4 tables, additive); `db/schema.rb` diff is additions + version only. 22 model tests: `22 runs, 77 assertions, 0 failures, 0 errors` |
| M2 | PASS | Stream tab + `StreamAdminController`. `stream_admin_test.rb`: `8 runs, 79 assertions, 0 failures, 0 errors` (anon/non-admin denied incl. JSON 403, CSRF enforced, full Start→profit→loss→duplicate→End→restart flow, stale window, accident past/now/undo/future, link rotate, render in all states, renders without the table) |
| M3 | PASS | `/overlay/:token(.json)`. `stream_overlay_public_test.rb`: `6 runs, 43 assertions, 0 failures`. Browser (Playwright/Chromium, 420×170): +175,000 → −55,000 within 4 s of an admin update, 4 days → 0 days after Record now, JSON blocked 36 s → dimmed + "reconnecting…", unblocked → recovered in < 7 s |
| M4 | PASS | `!accident` cog. Bot suite `102 passed` (86 existing + 16 new). Cross-app check on one DB at 6 UTC instants: Rails and Python returned identical counts (0,1,1,2,6,128) |
| M5 | PASS (local) | Combined Rails targeted run `PARALLEL_WORKERS=1`: `79 runs, 423 assertions, 0 failures, 0 errors, 0 skips`. Full suite `195 runs, 0 failures, 116 errors` — all 116 are the known stale `org_roles` fixture, same count as before |
| M6 | NOT STARTED | Needs owner GO, and must run from WSL (no Heroku CLI here). See release-runbook.md |

## Notes and known issues

- Running ≥ 50 Rails tests in one command switches Minitest to parallel worker DBs, which are built without the
  Extra Life SQL functions (`db:extra_life_sql` hook), so Extra Life tests then fail with `UndefinedFunction`.
  Pre-existing harness issue; use `PARALLEL_WORKERS=1`.
- 24-hour OBS soak not done (playbook P1). Overlay reloads itself every 6 h as a safety net.
- Pre-existing, untouched: `!version` shadowed by `!referral` (commands/base.py); 116 fixture errors.
