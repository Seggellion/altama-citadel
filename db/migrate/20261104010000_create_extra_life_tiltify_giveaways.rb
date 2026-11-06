# Extra Life / Tiltify event giveaways. Additive only: no existing column or row is changed.
# Contract: altama_sys/docs/extra-life-tiltify/contract.md (referenced from docs/extra-life-tiltify.md).
class CreateExtraLifeTiltifyGiveaways < ActiveRecord::Migration[7.0]
  def up
    create_table :extra_life_events do |t|
      t.bigint :bot_id, null: false
      t.string :name, null: false
      t.string :broadcaster_twitch_id, null: false
      t.string :broadcaster_login, null: false
      t.string :tiltify_campaign_url
      t.string :tiltify_campaign_id
      t.datetime :stream_start_at, null: false
      t.string :time_zone, null: false, default: "America/Vancouver"
      t.boolean :enabled, null: false, default: false
      t.datetime :sync_requested_at
      t.datetime :last_complete_sync_at
      t.string :last_sync_status
      t.string :last_sync_error
      t.timestamps
    end
    add_foreign_key :extra_life_events, :bots
    add_index :extra_life_events, :bot_id

    create_table :extra_life_event_operators do |t|
      t.bigint :extra_life_event_id, null: false
      t.bigint :user_id, null: false
      t.bigint :granted_by_user_id
      t.timestamps
    end
    add_foreign_key :extra_life_event_operators, :extra_life_events
    add_foreign_key :extra_life_event_operators, :users
    add_index :extra_life_event_operators, %i[extra_life_event_id user_id], unique: true, name: "index_el_operators_unique"

    add_column :giveaways, :extra_life_event_id, :bigint
    add_column :giveaways, :entry_state, :string
    add_column :giveaways, :winner_twitch_id, :string
    add_foreign_key :giveaways, :extra_life_events
    add_index :giveaways, :extra_life_event_id
    add_index :giveaways, %i[id extra_life_event_id], unique: true, name: "index_giveaways_on_id_and_event"
    add_check_constraint :giveaways,
      "(extra_life_event_id IS NULL AND entry_state IS NULL) OR (mode = 'extra-life-tiltify' AND extra_life_event_id IS NOT NULL AND entry_state IN ('open', 'frozen', 'finalized'))",
      name: "giveaways_event_mode_consistency"
    add_check_constraint :giveaways, "mode IS DISTINCT FROM 'extra-life-tiltify' OR extra_life_event_id IS NOT NULL",
      name: "giveaways_event_mode_requires_event"

    create_table :twitch_accounts do |t|
      t.string :twitch_user_id, null: false
      t.string :login, null: false
      t.string :display_name
      t.bigint :user_id
      t.string :link_conflict
      t.datetime :last_resolved_at
      t.timestamps
    end
    add_index :twitch_accounts, :twitch_user_id, unique: true
    add_index :twitch_accounts, "LOWER(login)", name: "index_twitch_accounts_on_lower_login"
    add_foreign_key :twitch_accounts, :users

    create_table :giveaway_ticket_sources do |t|
      t.bigint :giveaway_id, null: false
      t.string :twitch_user_id, null: false
      t.string :source, null: false
      t.boolean :active, null: false, default: true
      t.datetime :granted_at, null: false
      t.datetime :revoked_at
      t.string :revoke_reason
      t.timestamps
    end
    add_index :giveaway_ticket_sources, %i[giveaway_id twitch_user_id source], unique: true, name: "index_ticket_sources_unique"
    add_index :giveaway_ticket_sources, :twitch_user_id
    add_foreign_key :giveaway_ticket_sources, :giveaways
    add_foreign_key :giveaway_ticket_sources, :twitch_accounts, column: :twitch_user_id, primary_key: :twitch_user_id
    add_check_constraint :giveaway_ticket_sources, "source IN ('chat', 'donor')", name: "ticket_sources_source"
    add_check_constraint :giveaway_ticket_sources, "active OR revoked_at IS NOT NULL", name: "ticket_sources_revocation"

    create_table :external_donations do |t|
      t.string :provider, null: false, default: "tiltify"
      t.string :external_id, null: false
      t.string :campaign_id, null: false
      t.datetime :completed_at
      t.decimal :amount_value, precision: 12, scale: 2
      t.string :amount_currency
      t.string :donor_name
      t.string :provider_status, null: false
      t.string :status_source, null: false, default: "provider_list"
      t.bigint :status_confirmed_by_user_id
      t.datetime :status_confirmed_at
      t.string :status_note
      t.datetime :first_seen_at, null: false
      t.datetime :last_seen_at, null: false
      t.datetime :missing_since
      t.string :match_outcome, null: false, default: "UNPROCESSED"
      t.string :auto_twitch_user_id
      t.string :manual_twitch_user_id
      t.string :resolved_twitch_user_id
      t.bigint :manual_assigned_by_user_id
      t.datetime :manual_assigned_at
      t.string :manual_reason
      t.integer :verification_attempts, null: false, default: 0
      t.datetime :next_verification_at
      t.string :last_verification_error
      t.integer :revision, null: false, default: 1
      t.timestamps
    end
    add_index :external_donations, %i[provider external_id], unique: true
    add_index :external_donations, %i[campaign_id completed_at]
    add_index :external_donations, :resolved_twitch_user_id
    add_index :external_donations, :match_outcome
    %i[auto_twitch_user_id manual_twitch_user_id resolved_twitch_user_id].each do |col|
      add_foreign_key :external_donations, :twitch_accounts, column: col, primary_key: :twitch_user_id
    end
    add_foreign_key :external_donations, :users, column: :manual_assigned_by_user_id
    add_foreign_key :external_donations, :users, column: :status_confirmed_by_user_id
    add_check_constraint :external_donations, "provider_status IN ('completed', 'pending', 'missing', 'refunded')", name: "donations_status"
    add_check_constraint :external_donations, "status_source IN ('provider_list', 'operator_confirmed')", name: "donations_status_source"
    add_check_constraint :external_donations,
      "resolved_twitch_user_id IS NOT DISTINCT FROM COALESCE(manual_twitch_user_id, auto_twitch_user_id)",
      name: "donations_resolved_identity"
    add_check_constraint :external_donations,
      "manual_twitch_user_id IS NULL OR (manual_assigned_by_user_id IS NOT NULL AND manual_assigned_at IS NOT NULL)",
      name: "donations_manual_audited"
    add_check_constraint :external_donations,
      "status_source = 'provider_list' OR (status_confirmed_by_user_id IS NOT NULL AND status_confirmed_at IS NOT NULL)",
      name: "donations_status_confirmation_audited"

    create_table :donation_audit_events do |t|
      t.bigint :external_donation_id, null: false
      t.string :event_type, null: false
      t.bigint :actor_user_id
      t.jsonb :details, null: false, default: {}
      t.string :reason
      t.datetime :created_at, null: false
    end
    add_foreign_key :donation_audit_events, :external_donations
    add_foreign_key :donation_audit_events, :users, column: :actor_user_id
    add_index :donation_audit_events, :external_donation_id

    create_table :donation_sync_runs do |t|
      t.bigint :extra_life_event_id, null: false
      t.string :campaign_id
      t.string :kind, null: false
      t.string :status, null: false, default: "running"
      t.boolean :complete, null: false, default: false
      t.datetime :fetch_started_at, null: false
      t.datetime :finished_at
      t.integer :pages, null: false, default: 0
      t.integer :donations_seen, null: false, default: 0
      t.string :error_code
      t.string :error_message
      t.timestamps
    end
    add_foreign_key :donation_sync_runs, :extra_life_events
    add_index :donation_sync_runs, %i[extra_life_event_id created_at]
    add_check_constraint :donation_sync_runs, "status IN ('running', 'succeeded', 'failed')", name: "sync_runs_status"
    add_check_constraint :donation_sync_runs, "NOT complete OR status = 'succeeded'", name: "sync_runs_complete_only_on_success"

    create_table :giveaway_draw_attempts do |t|
      t.bigint :giveaway_id, null: false
      t.bigint :extra_life_event_id, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :cutoff_at, null: false
      t.string :requested_by_twitch_id
      t.string :blocking_reason
      t.jsonb :blocking_detail
      t.bigint :verification_sync_run_id
      t.jsonb :pool
      t.jsonb :exclusions
      t.jsonb :unresolved
      t.integer :total_weight
      t.string :result
      t.string :winner_twitch_user_id
      t.datetime :finalized_at
      t.datetime :cancelled_at
      t.bigint :cancelled_by_user_id
      t.string :cancel_reason
      t.string :announcement_state, null: false, default: "none"
      t.integer :announcement_attempts, null: false, default: 0
      t.datetime :announced_at
      t.timestamps
    end
    add_foreign_key :giveaway_draw_attempts, :giveaways
    add_foreign_key :giveaway_draw_attempts, :extra_life_events
    add_foreign_key :giveaway_draw_attempts, :donation_sync_runs, column: :verification_sync_run_id
    add_foreign_key :giveaway_draw_attempts, :twitch_accounts, column: :winner_twitch_user_id, primary_key: :twitch_user_id
    add_foreign_key :giveaway_draw_attempts, :users, column: :cancelled_by_user_id
    add_index :giveaway_draw_attempts, :giveaway_id, unique: true, where: "status IN ('pending', 'finalized')",
      name: "index_draw_attempts_one_live_per_giveaway"
    add_check_constraint :giveaway_draw_attempts, "status IN ('pending', 'finalized', 'cancelled')", name: "draw_attempts_status"
    add_check_constraint :giveaway_draw_attempts,
      "status <> 'finalized' OR (finalized_at IS NOT NULL AND pool IS NOT NULL AND result IN ('winner', 'no_eligible_entries') AND (result = 'winner') = (winner_twitch_user_id IS NOT NULL))",
      name: "draw_attempts_finalized_complete"
    add_check_constraint :giveaway_draw_attempts, "announcement_state IN ('none', 'pending', 'sent')", name: "draw_attempts_announcement"

    create_table :giveaway_awards do |t|
      t.bigint :giveaway_id, null: false
      t.bigint :extra_life_event_id, null: false
      t.string :twitch_user_id, null: false
      t.bigint :draw_attempt_id, null: false
      t.datetime :awarded_at, null: false
      t.timestamps
    end
    add_index :giveaway_awards, :giveaway_id, unique: true
    add_index :giveaway_awards, %i[extra_life_event_id twitch_user_id], unique: true, name: "index_awards_one_per_account_per_event"
    add_index :giveaway_awards, :draw_attempt_id, unique: true
    add_foreign_key :giveaway_awards, :twitch_accounts, column: :twitch_user_id, primary_key: :twitch_user_id
    add_foreign_key :giveaway_awards, :giveaway_draw_attempts, column: :draw_attempt_id
    add_foreign_key :giveaway_awards, :extra_life_events
    # The composite FK (award event = giveaway event) lives in the SQL file because schema.rb cannot dump it.
    execute File.read(Rails.root.join("db/sql/extra_life_giveaways_v1.sql"))
  end

  def down
    # Disposable databases only: production rollback disables the mode and keeps this audit data.
    execute File.read(Rails.root.join("db/sql/extra_life_giveaways_drop.sql"))
    drop_table :giveaway_awards
    drop_table :giveaway_draw_attempts
    drop_table :donation_sync_runs
    drop_table :donation_audit_events
    drop_table :external_donations
    drop_table :giveaway_ticket_sources
    remove_check_constraint :giveaways, name: "giveaways_event_mode_requires_event"
    remove_check_constraint :giveaways, name: "giveaways_event_mode_consistency"
    remove_index :giveaways, name: "index_giveaways_on_id_and_event"
    remove_foreign_key :giveaways, :extra_life_events
    remove_column :giveaways, :winner_twitch_id
    remove_column :giveaways, :entry_state
    remove_column :giveaways, :extra_life_event_id
    drop_table :twitch_accounts
    drop_table :extra_life_event_operators
    drop_table :extra_life_events
  end
end
