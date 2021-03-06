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

ActiveRecord::Schema.define(version: 20131128192042) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bitcoin_stats_snapshots", force: true do |t|
    t.decimal  "btc_mined",     precision: 13, scale: 8
    t.decimal  "usd_value",     precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mining_rig_id"
  end

  create_table "mining_rigs", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_date"
    t.string   "wallet_address"
    t.decimal  "btc_cost",                precision: 11, scale: 8
    t.decimal  "usd_cost",                precision: 9,  scale: 2
    t.decimal  "preexisting_btc_balance", precision: 11, scale: 8
    t.integer  "graph_interval",                                   default: 0
    t.boolean  "active",                                           default: true
    t.string   "pool_name",                                        default: "eligius"
    t.string   "pool_api_key"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_hash"
    t.string   "password_salt"
  end

end
