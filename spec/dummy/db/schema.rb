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

ActiveRecord::Schema.define(version: 20150111185006) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "test_user_friendships", force: true do |t|
    t.integer  "test_user_id"
    t.integer  "friend_id"
    t.boolean  "pending",      default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "test_user_friendships", ["friend_id"], name: "index_test_user_friendships_on_friend_id", using: :btree
  add_index "test_user_friendships", ["test_user_id", "friend_id"], name: "index_test_user_friendships_on_test_user_id_and_friend_id", unique: true, using: :btree
  add_index "test_user_friendships", ["test_user_id"], name: "index_test_user_friendships_on_test_user_id", using: :btree

  create_table "test_users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.boolean  "pending",    default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_friendships", ["friend_id"], name: "index_user_friendships_on_friend_id", using: :btree
  add_index "user_friendships", ["user_id", "friend_id"], name: "index_user_friendships_on_user_id_and_friend_id", unique: true, using: :btree
  add_index "user_friendships", ["user_id"], name: "index_user_friendships_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
