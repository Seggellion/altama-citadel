# Stream overlay release runbook

Run from the owner's WSL checkouts (`/home/dusti/altama-citadel`, `/home/dusti/altama_sys`) with the Heroku CLI.
**Only with the owner's GO**, and not while a giveaway draw is pending (a bot deploy restarts the worker, and on
startup the bot posts "Good Morning Dave." in chat — existing behaviour).

Order: Rails code → one migration → web restart → Rails smoke → bot. Old bot ignores the new tables; the new bot
answers "offline" if the table is missing; the new Rails hides the Stream tab until the table exists.

## 0. Preflight (read-only)

```bash
heroku releases -a altama-energy -n 3     # note current release = Rails rollback target
heroku releases -a altama-exe -n 3        # note current release = bot rollback target
heroku ps -a altama-exe                   # web.1 + worker.1 up
heroku pg:backups:capture -a altama-energy   # restorable snapshot; confirm it finished
```

## 1. Rails (altama-energy)

```bash
cd /home/dusti/altama-citadel && git checkout main && git pull   # after the PR is merged
git push heroku main                                             # web restarts
heroku run -a altama-energy -- bin/rails db:migrate              # exactly once: four new tables, no changes to old ones
heroku ps:restart web -a altama-energy                           # drops the cached "table missing" so the Stream tab appears
```

The migration only creates tables. Its foreign keys to `bots`/`users` take SHARE ROW EXCLUSIVE locks, which do not
conflict with the bot's idle read locks. If it still hangs more than ~30 s, restart the bot worker
(`heroku ps:restart worker -a altama-exe`), as in the Extra Life runbook. Never kill sessions by hand.

## 2. Rails smoke (no public output)

1. Desktop → ALTAMA.EXE → **Stream** tab renders (NOT STARTED, No accident on record, No OBS link yet).
2. **Make OBS link**, copy it. Open it in a private window: two grey windows, "Session not started".
3. `curl -s -o /dev/null -w "%{http_code}\n" https://<host>/overlay/not-a-real-token.json` → `404`.
4. Enter the real wallet, **Start**; set the past accident date (or **Record accident now**). The private window
   updates within ~3 s.
5. Add the link to OBS as a Browser Source, 420 × 170. Transparent by default in OBS.

## 3. Bot (altama-exe)

```bash
cd /home/dusti/altama_sys && git checkout main && git pull       # after the PR is merged
git push heroku main                                             # restarts web + worker
heroku ps -a altama-exe
heroku logs -a altama-exe --dyno worker -n 100 | grep -E "Traceback|accident"
```

Then the owner types `!accident` once in their own chat. Expected: the same number the overlay shows.

## Rollback

- Bot: `heroku rollback v<previous> -a altama-exe`. `!accident` disappears; nothing else changes.
- Rails: `heroku rollback v<previous> -a altama-energy`. Old Rails ignores the new tables.
- Overlay leaked or wrong: untick **Overlay on** (or **Make new link…**) in the Stream tab; the old URL 404s at once.
- Schema: leave the tables. Never `db:rollback` in production.
