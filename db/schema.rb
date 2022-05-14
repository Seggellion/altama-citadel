# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_05_14_060310) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: 6, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "badges", force: :cascade do |t|
    t.string "badge_name"
    t.string "badge_description"
    t.string "badge_image"
    t.string "badge_color"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "commodities", force: :cascade do |t|
    t.string "symbol"
    t.string "name"
    t.float "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "control_points", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.integer "event_id"
    t.integer "location_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "capture_team_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.integer "guildstone_id"
    t.integer "parent_department_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "discord_users", force: :cascade do |t|
    t.string "username", null: false
    t.string "discord_id"
    t.string "role"
  end

  create_table "event_records", force: :cascade do |t|
    t.integer "event_type"
    t.integer "event_id"
    t.datetime "start_time", precision: 6
    t.datetime "end_time", precision: 6
    t.integer "duration"
    t.integer "team_id"
    t.integer "control_point_id"
    t.integer "points"
    t.integer "rank_placement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "action"
  end

  create_table "event_teams", force: :cascade do |t|
    t.integer "event_id"
    t.integer "team_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["team_id", "event_id"], name: "one_team_per_event", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.integer "owner_id"
    t.datetime "start_date", precision: 6
    t.integer "tournament_id"
    t.string "description"
    t.integer "event_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "capture_limit"
    t.string "staff_code"
  end

  create_table "guildstones", force: :cascade do |t|
    t.string "charter"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.integer "location_type"
    t.integer "parent"
    t.boolean "trade_port"
    t.string "image"
    t.string "classification"
    t.integer "system"
    t.boolean "habitable"
    t.string "affiliation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "starfarer_image"
    t.string "ocean_color"
    t.string "surface_color"
  end

  create_table "manufacturers", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "origin_location"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "logo"
  end

  create_table "position_nominations", force: :cascade do |t|
    t.integer "position_id"
    t.integer "nominee_id"
    t.string "campaign_description"
    t.text "resume"
    t.integer "nominator_id"
    t.integer "guildstone_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "positions", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.integer "department_id"
    t.integer "guildstone_id"
    t.integer "term_length_days", default: 185
    t.float "compensation"
    t.integer "parent_position_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id"
    t.integer "rfa_id"
    t.integer "reviewee_id"
    t.integer "rating"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "rfa_id"], name: "one_review_per_rfa", unique: true
  end

  create_table "rewards", force: :cascade do |t|
    t.string "title"
    t.float "amount"
  end

  create_table "rfa_products", force: :cascade do |t|
    t.integer "commodity_id"
    t.integer "rfa_id"
    t.float "amount"
    t.float "market_price"
    t.float "selling_price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["rfa_id", "commodity_id"], name: "one_product_per_rfa", unique: true
  end

  create_table "rfas", force: :cascade do |t|
    t.string "title"
    t.string "rsi_username"
    t.string "description"
    t.integer "user_id"
    t.integer "status_id"
    t.integer "location_id"
    t.integer "ship_id"
    t.integer "priority_id"
    t.integer "aec_rewards"
    t.integer "user_assigned_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "usership_id"
    t.float "servicefee", default: 0.0
  end

  create_table "rsi_users", force: :cascade do |t|
    t.string "username", null: false
    t.string "title"
    t.string "link"
  end

  create_table "rules", force: :cascade do |t|
    t.integer "guildstone_id"
    t.integer "position_id"
    t.integer "user_id"
    t.string "description"
    t.integer "term_length_days", default: 185
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title"
  end

  create_table "ships", force: :cascade do |t|
    t.string "model"
    t.integer "manufacturer_id"
    t.integer "scu"
    t.integer "crew"
    t.integer "length"
    t.integer "beam"
    t.integer "height"
    t.integer "msrp"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "year_introduced"
    t.string "ship_image_primary"
    t.string "ship_image_secondary"
    t.string "image_topdown"
    t.float "hyd_fuel_capacity"
    t.float "qnt_fuel_capacity"
    t.float "liquid_storage_capacity"
    t.float "mass"
    t.string "vehicle_type"
    t.string "career"
    t.string "role"
    t.integer "size"
    t.integer "hp"
    t.integer "speed"
    t.integer "afterburner_speed"
    t.integer "ifcs_pitch_max"
    t.integer "ifcs_yaw_max"
    t.integer "ifcs_roll_max"
    t.string "shield_face_type"
    t.integer "armor_physical_dmg_reduction"
    t.integer "armor_energy_dmg_reduction"
    t.integer "armor_distortion_dmg_reduction"
    t.integer "armor_em_signal_reduction"
    t.integer "armor_ir_signal_reduction"
    t.integer "armor_cs_signal_reduction"
    t.integer "capacitor_crew_load"
    t.integer "capacitor_crew_regen"
    t.integer "capacitor_turret_load"
    t.integer "capacitor_turret_regen"
  end

  create_table "task_managers", force: :cascade do |t|
    t.integer "user_id"
    t.string "task_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name"
    t.string "author"
    t.string "icon"
    t.integer "task_manager_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state"
    t.string "view"
  end

  create_table "teams", force: :cascade do |t|
    t.string "team_name"
    t.integer "owner_id"
    t.string "description"
    t.integer "karma"
    t.integer "fame"
    t.string "website"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "team_color"
  end

  create_table "user_badges", force: :cascade do |t|
    t.integer "user_id"
    t.integer "badge_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "badge_id"], name: "one_badge_per_user", unique: true
  end

  create_table "user_position_histories", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.string "description"
    t.integer "department_id"
    t.date "term_end"
    t.float "compensation"
    t.integer "guildstone_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "nomination_id"
  end

  create_table "user_positions", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.string "description"
    t.integer "department_id"
    t.float "compensation"
    t.integer "position_id"
    t.integer "guildstone_id"
    t.date "term_end"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "nomination_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: 6
    t.datetime "remember_created_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.integer "user_type", default: 100
    t.string "profile_image"
    t.string "provider"
    t.string "uid"
    t.string "rsi_username"
    t.boolean "rsi_verify"
    t.integer "aec", default: 0, null: false
    t.integer "fame", default: 0, null: false
    t.integer "karma", default: 0, null: false
    t.datetime "last_login", precision: 6
    t.string "desktop_background"
    t.string "org_title"
    t.string "crew_title"
    t.string "error"
    t.integer "background_style"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["rsi_username"], name: "index_users_on_rsi_username", unique: true
  end

  create_table "userships", force: :cascade do |t|
    t.string "ship_name"
    t.string "ship_image"
    t.integer "year_purchased"
    t.string "description"
    t.integer "ship_id"
    t.integer "user_id"
    t.boolean "show_information"
    t.boolean "primary"
    t.boolean "fleetship"
    t.string "paint"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.string "ship_serial"
    t.integer "pledge_id"
    t.string "pledge_name"
    t.date "pledge_date"
    t.string "pledge_cost"
    t.boolean "lti"
    t.boolean "warbond"
  end

  create_table "votes", force: :cascade do |t|
    t.boolean "vote"
    t.integer "user_id"
    t.integer "position_id"
    t.integer "rule_id"
    t.integer "position_nomination_id"
    t.string "feedback"
    t.integer "guildstone_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
