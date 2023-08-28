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

ActiveRecord::Schema[7.0].define(version: 2023_08_28_012438) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channel_members", force: :cascade do |t|
    t.bigint "slack_channel_id", null: false
    t.bigint "slack_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slack_channel_id", "slack_account_id"], name: "index_channel_members_on_slack_channel_id_and_slack_account_id", unique: true
  end

  create_table "observed_members", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "channel_member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "channel_member_id"], name: "index_observed_members_on_user_id_and_channel_member_id", unique: true
  end

  create_table "slack_accounts", force: :cascade do |t|
    t.string "account_id", null: false
    t.string "name", null: false
    t.text "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_slack_accounts_on_account_id", unique: true
  end

  create_table "slack_channels", force: :cascade do |t|
    t.string "channel_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_slack_channels_on_channel_id", unique: true
    t.index ["name"], name: "index_slack_channels_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "channel_members", "slack_accounts"
  add_foreign_key "channel_members", "slack_channels"
  add_foreign_key "observed_members", "channel_members"
  add_foreign_key "observed_members", "users"
end
