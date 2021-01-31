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

ActiveRecord::Schema.define(version: 2021_01_30_192201) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "image"
    t.string "action"
    t.integer "draw_chance"
    t.integer "level"
    t.string "element"
    t.string "bad_things"
    t.string "rewards_treasure"
    t.string "good_against"
    t.string "bad_against"
    t.integer "good_against_value"
    t.integer "bad_against_value"
    t.integer "element_modifier"
    t.integer "atk_points"
    t.string "item_category"
    t.integer "has_combination"
    t.integer "level_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type"
  end

  create_table "gameboards", force: :cascade do |t|
    t.string "current_state"
    t.integer "player_atk"
    t.integer "monster_atk"
    t.boolean "asked_help"
    t.boolean "success"
    t.boolean "can_flee"
    t.integer "shared_reward"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "avatar"
    t.integer "level"
    t.integer "attack"
    t.boolean "is_cursed"
    t.bigint "gameboard_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gameboard_id"], name: "index_players_on_gameboard_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "players", "gameboards"
end
