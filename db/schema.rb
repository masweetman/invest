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

ActiveRecord::Schema.define(version: 4) do

  create_table "companies", force: :cascade do |t|
    t.string   "ticker",           limit: 255
    t.float    "price",            limit: 24
    t.float    "price_change_pct", limit: 24
    t.float    "calculated_pe",    limit: 24
    t.float    "div_yield",        limit: 24
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "dividends", force: :cascade do |t|
    t.float    "value",      limit: 24
    t.integer  "year",       limit: 4
    t.integer  "company_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "dividends", ["company_id"], name: "index_dividends_on_company_id", using: :btree

  create_table "earnings", force: :cascade do |t|
    t.float    "value",      limit: 24
    t.integer  "year",       limit: 4
    t.integer  "company_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "earnings", ["company_id"], name: "index_earnings_on_company_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "value",      limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_foreign_key "dividends", "companies"
  add_foreign_key "earnings", "companies"
end
