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

ActiveRecord::Schema.define(version: 2022_01_26_051333) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "control_points", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.integer "event_id"
    t.integer "location_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "capture_team_id"
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
    t.integer "total_fuel"
    t.integer "total_price"
    t.integer "total_cost"
    t.integer "aec_rewards"
    t.integer "user_assigned_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ships", force: :cascade do |t|
    t.string "model"
    t.integer "make_id"
    t.integer "scu"
    t.integer "crew"
    t.integer "fuel"
    t.integer "quantum"
    t.integer "length"
    t.integer "beam"
    t.integer "height"
    t.integer "weight"
    t.integer "msrp"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: 6
    t.datetime "remember_created_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.integer "user_type"
    t.string "profile_image"
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
