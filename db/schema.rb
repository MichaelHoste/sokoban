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

ActiveRecord::Schema.define(version: 20190704131044) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "level_user_links", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.integer  "level_id",              limit: 4
    t.text     "uncompressed_path",     limit: 65535
    t.text     "compressed_path",       limit: 65535
    t.integer  "pushes",                limit: 4
    t.integer  "moves",                 limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "best_level_user_score",               default: false, null: false
  end

  add_index "level_user_links", ["best_level_user_score"], name: "index_level_user_links_on_best_level_user_score", using: :btree
  add_index "level_user_links", ["created_at"], name: "index_level_user_links_on_created_at", using: :btree
  add_index "level_user_links", ["level_id"], name: "index_level_user_links_on_level_id", using: :btree
  add_index "level_user_links", ["moves"], name: "index_level_user_links_on_moves", using: :btree
  add_index "level_user_links", ["pushes"], name: "index_level_user_links_on_pushes", using: :btree
  add_index "level_user_links", ["user_id"], name: "index_level_user_links_on_user_id", using: :btree

  create_table "levels", force: :cascade do |t|
    t.integer  "pack_id",         limit: 4
    t.string   "name",            limit: 255
    t.integer  "width",           limit: 4
    t.integer  "height",          limit: 4
    t.string   "copyright",       limit: 255
    t.text     "grid",            limit: 65535
    t.text     "grid_with_floor", limit: 65535
    t.integer  "boxes_number",    limit: 4
    t.integer  "goals_number",    limit: 4
    t.integer  "pusher_pos_m",    limit: 4
    t.integer  "pusher_pos_n",    limit: 4
    t.integer  "won_count",       limit: 4
    t.integer  "complexity",      limit: 4,     default: 0
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "slug",            limit: 255
  end

  add_index "levels", ["complexity"], name: "index_levels_on_complexity", using: :btree
  add_index "levels", ["name"], name: "index_levels_on_name", using: :btree
  add_index "levels", ["pack_id"], name: "index_levels_on_pack_id", using: :btree
  add_index "levels", ["slug"], name: "index_levels_on_slug", using: :btree
  add_index "levels", ["won_count"], name: "index_levels_on_won_count", using: :btree

  create_table "pack_user_links", force: :cascade do |t|
    t.integer  "pack_id",          limit: 4
    t.integer  "user_id",          limit: 4
    t.integer  "won_levels_count", limit: 4,     default: 0
    t.text     "won_levels_list",  limit: 65535
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "packs", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "file_name",    limit: 255
    t.text     "description",  limit: 65535
    t.string   "email",        limit: 255
    t.string   "url",          limit: 255
    t.string   "copyright",    limit: 255
    t.integer  "max_width",    limit: 4
    t.integer  "max_height",   limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "levels_count", limit: 4,     default: 0
    t.string   "slug",         limit: 255
  end

  add_index "packs", ["name"], name: "index_packs_on_name", using: :btree
  add_index "packs", ["slug"], name: "index_packs_on_slug", using: :btree

  create_table "user_user_links", force: :cascade do |t|
    t.integer  "user_id",                 limit: 8
    t.integer  "friend_id",               limit: 8
    t.datetime "notified_at",                       default: '2013-03-17 00:00:00'
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.integer  "levels_to_solve_count",   limit: 4, default: 0,                     null: false
    t.integer  "scores_to_improve_count", limit: 4, default: 0,                     null: false
  end

  add_index "user_user_links", ["friend_id"], name: "index_user_user_links_on_friend_id", using: :btree
  add_index "user_user_links", ["user_id"], name: "index_user_user_links_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "email",               limit: 255
    t.text     "picture",             limit: 65535
    t.string   "gender",              limit: 255
    t.string   "locale",              limit: 255
    t.integer  "f_id",                limit: 8
    t.string   "f_token",             limit: 255
    t.string   "f_first_name",        limit: 255
    t.string   "f_middle_name",       limit: 255
    t.string   "f_last_name",         limit: 255
    t.string   "f_username",          limit: 255
    t.string   "f_link",              limit: 255
    t.integer  "f_timezone",          limit: 4
    t.datetime "f_updated_time"
    t.boolean  "f_verified"
    t.boolean  "f_expires"
    t.datetime "f_expires_at"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.datetime "registered_at"
    t.integer  "friends_count",       limit: 4,     default: 0,                     null: false
    t.integer  "total_won_levels",    limit: 4,     default: 0,                     null: false
    t.datetime "friends_updated_at"
    t.datetime "send_invitations_at",               default: '2013-03-11 00:00:00'
    t.boolean  "like_fan_page",                     default: false
    t.boolean  "full_game",                         default: false
    t.boolean  "mailing_unsubscribe",               default: false
    t.datetime "next_mailing_at",                   default: '2013-04-21 19:40:40'
    t.string   "slug",                limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["f_id"], name: "index_users_on_f_id", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["registered_at"], name: "index_users_on_registered_at", using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", using: :btree

end
