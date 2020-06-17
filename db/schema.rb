# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200615053420) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "change"
    t.boolean "tomorrow"
    t.datetime "finished_plan_at"
    t.string "business_process_content"
    t.string "instructor_confirmation"
    t.integer "mark_instructor_confirmation"
    t.datetime "started_before_at"
    t.datetime "finished_before_at"
    t.datetime "apploval_month"
    t.integer "mark_apploval_confirmation"
    t.integer "mark_change_confirmation"
    t.string "apploval_confirmation"
    t.string "change_confirmation"
    t.date "search"
    t.boolean "change_at"
    t.boolean "tomorrow_at"
    t.boolean "change_apploval"
    t.datetime "started_edit_at"
    t.datetime "finished_edit_at"
    t.string "overtime_instructor_confirmation"
    t.string "edit_change_confirmation"
    t.date "change_date"
    t.string "edit_apploval_confirmation"
    t.datetime "change_month"
    t.datetime "overtime_month"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "base_name"
    t.string "base_type"
    t.integer "base_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.datetime "basic_time", default: "2020-06-16 23:00:00"
    t.datetime "work_time", default: "2020-06-16 22:30:00"
    t.string "search"
    t.string "uid"
    t.integer "employee_number"
    t.boolean "superior"
    t.string "affiliation"
    t.datetime "basic_work_time", default: "2020-06-16 23:00:00"
    t.datetime "designated_work_start_time", default: "2020-06-17 01:00:00"
    t.datetime "designated_work_end_time", default: "2020-06-17 09:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
