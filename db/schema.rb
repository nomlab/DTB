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

ActiveRecord::Schema.define(version: 20151120055740) do

  create_table "missions", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "deadline"
    t.integer  "state_id"
    t.string   "keyword"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
  end

  add_index "missions", ["depth"], name: "index_missions_on_depth"
  add_index "missions", ["lft"], name: "index_missions_on_lft"
  add_index "missions", ["parent_id"], name: "index_missions_on_parent_id"
  add_index "missions", ["rgt"], name: "index_missions_on_rgt"

  create_table "states", force: :cascade do |t|
    t.string   "name"
    t.string   "color"
    t.integer  "position"
    t.boolean  "default",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "deadline"
    t.integer  "state_id"
    t.string   "keyword"
    t.integer  "mission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_entries", force: :cascade do |t|
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

  create_table "unified_histories", force: :cascade do |t|
    t.string   "title"
    t.string   "path"
    t.string   "type"
    t.string   "r_path"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "importance"
  end

  add_index "unified_histories", ["type"], name: "index_unified_histories_on_type"

end
