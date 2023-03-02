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

ActiveRecord::Schema[7.0].define(version: 2023_02_28_215829) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.integer "room_bill"
    t.integer "min_head_count"
    t.integer "max_head_count"
    t.integer "min_term"
    t.integer "max_term"
    t.integer "room_type_id"
    t.string "only"
  end

  create_table "reserves", force: :cascade do |t|
    t.integer "plan_id", null: false
    t.integer "total_bill", null: false
    t.date "date", null: false
    t.integer "term", null: false
    t.integer "head_count", null: false
    t.string "username", null: false
    t.boolean "breakfast", default: false
    t.boolean "early_check_in", default: false
    t.boolean "sightseeing", default: false
    t.string "contact", null: false
    t.string "email"
    t.string "tel"
    t.string "comment"
    t.string "session_token"
    t.datetime "session_expires_at"
    t.boolean "is_definitive_regist", default: false, null: false
  end

  create_table "room_types", force: :cascade do |t|
    t.string "room_type_name"
    t.string "room_category_name"
    t.integer "min_capacity"
    t.integer "max_capacity"
    t.integer "room_size"
    t.string "facilities", array: true
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "username", null: false
    t.string "nickname"
    t.string "image"
    t.string "email", null: false
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rank", default: "premium"
    t.string "address"
    t.string "tel"
    t.integer "gender"
    t.date "birthday"
    t.boolean "notification", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

end
