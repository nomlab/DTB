# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20131210025008) do

  create_table "missions", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "deadline"
    t.integer  "state_id"
    t.string   "keyword"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", force: true do |t|
    t.string   "name"
    t.string   "color"
    t.integer  "position"
    t.boolean  "default",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "deadline"
    t.integer  "state_id"
    t.string   "keyword"
    t.integer  "mission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_entries", force: true do |t|
    t.string   "name"
    t.string   "keyword"
    t.text     "comment"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "toggl_time_entry_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unified_histories", force: true do |t|
    t.string   "title"
    t.string   "path"
    t.string   "history_type"
    t.string   "r_path"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
