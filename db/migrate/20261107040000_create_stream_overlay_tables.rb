# Stream overlay: wallet sessions (net aUEC since Start), fuelling accidents (days since), and the public OBS overlay.
# Additive only: four new tables, no existing column or row changes. The bot reads fuelling_accidents + bots
# (contract: docs/stream-overlay/contract.md).
class CreateStreamOverlayTables < ActiveRecord::Migration[7.0]
  MAX_AUEC = 999_999_999_999

  def change
    create_table :stream_wallet_sessions do |t|
      t.bigint :bot_id, null: false
      t.string :status, null: false, default: "active"
      t.bigint :starting_balance_auec, null: false
      t.bigint :current_balance_auec, null: false
      t.datetime :started_at, null: false
      t.datetime :balance_updated_at, null: false
      t.datetime :ended_at
      t.bigint :started_by_id
      t.bigint :ended_by_id
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end
    add_foreign_key :stream_wallet_sessions, :bots
    add_foreign_key :stream_wallet_sessions, :users, column: :started_by_id
    add_foreign_key :stream_wallet_sessions, :users, column: :ended_by_id
    add_index :stream_wallet_sessions, :bot_id
    # At most one live session per bot: a second Start fails in the database even if two requests race.
    add_index :stream_wallet_sessions, :bot_id, unique: true, where: "status = 'active'", name: "index_stream_wallet_sessions_one_active"
    add_check_constraint :stream_wallet_sessions, "status IN ('active', 'ended')", name: "stream_wallet_sessions_status"
    add_check_constraint :stream_wallet_sessions, "(status = 'ended') = (ended_at IS NOT NULL)", name: "stream_wallet_sessions_ended_at"
    add_check_constraint :stream_wallet_sessions,
                         "starting_balance_auec BETWEEN 0 AND #{MAX_AUEC} AND current_balance_auec BETWEEN 0 AND #{MAX_AUEC}",
                         name: "stream_wallet_sessions_balance_range"

    # Append-only audit of every balance the admin entered. idempotency_key absorbs double-clicks and resubmits.
    create_table :stream_wallet_entries do |t|
      t.bigint :stream_wallet_session_id, null: false
      t.string :kind, null: false
      t.bigint :balance_auec, null: false
      t.bigint :entered_by_id
      t.string :idempotency_key, null: false
      t.datetime :created_at, null: false
    end
    add_foreign_key :stream_wallet_entries, :stream_wallet_sessions
    add_foreign_key :stream_wallet_entries, :users, column: :entered_by_id
    add_index :stream_wallet_entries, %i[stream_wallet_session_id idempotency_key], unique: true, name: "index_stream_wallet_entries_idempotency"
    add_check_constraint :stream_wallet_entries, "kind IN ('start', 'update')", name: "stream_wallet_entries_kind"
    add_check_constraint :stream_wallet_entries, "balance_auec BETWEEN 0 AND #{MAX_AUEC}", name: "stream_wallet_entries_balance_range"

    # Append-only. The current accident is the latest non-voided row by occurred_at; a mistake is voided, never edited.
    create_table :fuelling_accidents do |t|
      t.bigint :bot_id, null: false
      t.datetime :occurred_at, null: false
      t.date :occurred_on, null: false
      t.string :time_zone, null: false, default: "America/Vancouver"
      t.string :source, null: false, default: "now"
      t.bigint :recorded_by_id
      t.datetime :voided_at
      t.bigint :voided_by_id
      t.timestamps
    end
    add_foreign_key :fuelling_accidents, :bots
    add_foreign_key :fuelling_accidents, :users, column: :recorded_by_id
    add_foreign_key :fuelling_accidents, :users, column: :voided_by_id
    add_index :fuelling_accidents, %i[bot_id occurred_at]
    add_check_constraint :fuelling_accidents, "source IN ('now', 'historic')", name: "fuelling_accidents_source"

    create_table :stream_overlays do |t|
      t.bigint :bot_id, null: false
      t.string :token_digest
      t.datetime :token_rotated_at
      t.boolean :enabled, null: false, default: true
      t.string :accident_caption, null: false, default: "Days since last fuelling accident"
      t.timestamps
    end
    add_foreign_key :stream_overlays, :bots
    add_index :stream_overlays, :bot_id, unique: true
    add_index :stream_overlays, :token_digest, unique: true
  end
end
