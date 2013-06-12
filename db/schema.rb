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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130612144242) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "level_user_links", :force => true do |t|
    t.integer  "user_id"
    t.integer  "level_id"
    t.text     "uncompressed_path"
    t.text     "compressed_path"
    t.integer  "pushes"
    t.integer  "moves"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.boolean  "best_level_user_score", :default => false, :null => false
  end

  add_index "level_user_links", ["level_id"], :name => "index_level_user_links_on_level_id"
  add_index "level_user_links", ["moves"], :name => "index_level_user_links_on_moves"
  add_index "level_user_links", ["pushes"], :name => "index_level_user_links_on_pushes"
  add_index "level_user_links", ["user_id"], :name => "index_level_user_links_on_user_id"

  create_table "levels", :force => true do |t|
    t.integer  "pack_id"
    t.string   "name"
    t.integer  "width"
    t.integer  "height"
    t.string   "copyright"
    t.text     "grid"
    t.text     "grid_with_floor"
    t.integer  "boxes_number"
    t.integer  "goals_number"
    t.integer  "pusher_pos_m"
    t.integer  "pusher_pos_n"
    t.integer  "won_count"
    t.integer  "complexity",      :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "slug"
  end

  add_index "levels", ["complexity"], :name => "index_levels_on_complexity"
  add_index "levels", ["name"], :name => "index_levels_on_name"
  add_index "levels", ["pack_id"], :name => "index_levels_on_pack_id"
  add_index "levels", ["slug"], :name => "index_levels_on_slug"
  add_index "levels", ["won_count"], :name => "index_levels_on_won_count"

  create_table "pack_user_links", :force => true do |t|
    t.integer  "pack_id"
    t.integer  "user_id"
    t.integer  "won_levels_count", :default => 0
    t.text     "won_levels_list"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "packs", :force => true do |t|
    t.string   "name"
    t.string   "file_name"
    t.text     "description"
    t.string   "email"
    t.string   "url"
    t.string   "copyright"
    t.integer  "max_width"
    t.integer  "max_height"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "levels_count", :default => 0
    t.string   "slug"
  end

  add_index "packs", ["name"], :name => "index_packs_on_name"
  add_index "packs", ["slug"], :name => "index_packs_on_slug"

  create_table "user_user_links", :force => true do |t|
    t.integer  "user_id",     :limit => 8
    t.integer  "friend_id",   :limit => 8
    t.datetime "notified_at",              :default => '2013-03-17 00:00:00'
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
  end

  add_index "user_user_links", ["friend_id"], :name => "index_user_user_links_on_friend_id"
  add_index "user_user_links", ["user_id"], :name => "index_user_user_links_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "picture"
    t.string   "gender"
    t.string   "locale"
    t.integer  "f_id",                :limit => 8
    t.string   "f_token"
    t.string   "f_first_name"
    t.string   "f_middle_name"
    t.string   "f_last_name"
    t.string   "f_username"
    t.string   "f_link"
    t.integer  "f_timezone"
    t.datetime "f_updated_time"
    t.boolean  "f_verified"
    t.boolean  "f_expires"
    t.datetime "f_expires_at"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.datetime "registered_at"
    t.integer  "friends_count",                    :default => 0,                     :null => false
    t.integer  "total_won_levels",                 :default => 0,                     :null => false
    t.datetime "friends_updated_at"
    t.datetime "send_invitations_at",              :default => '2013-03-11 00:00:00'
    t.boolean  "like_fan_page",                    :default => false
    t.boolean  "full_game",                        :default => false
    t.boolean  "mailing_unsubscribe",              :default => false
    t.datetime "next_mailing_at",                  :default => '2013-04-21 19:40:40'
    t.string   "slug"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["f_id"], :name => "index_users_on_f_id", :unique => true
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["registered_at"], :name => "index_users_on_registered_at"
  add_index "users", ["slug"], :name => "index_users_on_slug"

end
