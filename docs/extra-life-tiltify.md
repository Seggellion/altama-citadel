# Extra Life / Tiltify event giveaways

The shared contract (provider evidence, matching rules, data invariants) and the execution log live in the bot repo,
`Seggellion/altama_sys`: `docs/extra-life-tiltify/contract.md` and `docs/extra-life-tiltify/execution-log.md`.
This repo owns the schema:

- Migration `db/migrate/20261104010000_create_extra_life_tiltify_giveaways.rb` (additive).
- SQL functions `db/sql/extra_life_giveaways_v1.sql`: `extra_life_donor_support`, `extra_life_refresh_donor_sources`,
  `extra_life_pool`, `extra_life_draw_blockers`, `extra_life_unresolved_counts`. Both the bot and Rails call these;
  they are the single authority for donor tickets, odds/preview and draw blocking. `schema.rb` cannot hold functions,
  so `lib/tasks/extra_life_sql.rake` re-applies them after `db:schema:load` / `db:test:prepare`.
- Never edit a released `extra_life_giveaways_vN.sql`; add `vN+1` plus a migration that executes it.

Tests (isolated database only):

    RAILS_ENV=test DATABASE_URL=postgres://citadel:citadel@localhost:5432/altama_giveaway_test bin/rails test \
      test/models/giveaway_validation_test.rb test/models/extra_life_schema_test.rb test/integration/giveaway_authorization_test.rb \
      test/integration/extra_life_operator_test.rb test/integration/extra_life_panel_render_test.rb

Operator and release runbooks: `altama_sys/docs/extra-life-tiltify/operator-runbook.md`, `release-runbook.md`.
