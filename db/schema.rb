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

ActiveRecord::Schema[8.1].define(version: 2026_11_04_035517) do
  create_table "report_months", force: :cascade do |t|
    t.integer "report_id", null: false
    t.integer "month", null: false
    t.integer "status"
    t.integer "total_insulin"
    t.integer "total_basal"
    t.integer "total_bolus"
    t.integer "highest_bg"
    t.date "highest_bg_date"
    t.integer "lowest_bg"
    t.date "lowest_bg_date"
    t.integer "days_in_range"
    t.integer "biggest_bolus"
    t.date "biggest_bolus_date"
    t.integer "bolus_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_report_months_on_report_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "year", default: 2026
    t.string "slug", null: false
    t.integer "status"
    t.boolean "include_insulin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_insulin"
    t.integer "total_basal"
    t.integer "total_bolus"
    t.integer "bolus_count"
    t.integer "days_in_range"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "nightscout_host"
    t.string "nightscout_token"
    t.string "timezone"
    t.float "range_min", default: 70.0
    t.float "range_max", default: 180.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unit"
  end

  add_foreign_key "report_months", "reports"
  add_foreign_key "reports", "users"
end
