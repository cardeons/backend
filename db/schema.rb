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

ActiveRecord::Schema.define(version: 2021_02_02_181658) do

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

  create_table "cards_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "card_id", null: false
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
    t.bigint "current_player"
    t.index ["current_player"], name: "index_gameboards_on_current_player"
  end

  create_table "graveyards", force: :cascade do |t|
    t.bigint "gameboard_id", null: false
    t.bigint "ingamedeck_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gameboard_id"], name: "index_graveyards_on_gameboard_id"
    t.index ["ingamedeck_id"], name: "index_graveyards_on_ingamedeck_id"
  end

  create_table "handcards", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_handcards_on_player_id"
  end

  create_table "ingamedecks", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.bigint "gameboard_id", null: false
    t.string "cardable_type"
    t.bigint "cardable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_id"], name: "index_ingamedecks_on_card_id"
    t.index ["cardable_type", "cardable_id"], name: "index_ingamedecks_on_cardable"
    t.index ["gameboard_id"], name: "index_ingamedecks_on_gameboard_id"
  end

  create_table "interceptcards", force: :cascade do |t|
    t.bigint "gameboard_id", null: false
    t.bigint "ingamedeck_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gameboard_id"], name: "index_interceptcards_on_gameboard_id"
    t.index ["ingamedeck_id"], name: "index_interceptcards_on_ingamedeck_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_inventories_on_player_id"
  end

  create_table "monsterones", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_monsterones_on_player_id"
  end

  create_table "monsterthrees", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_monsterthrees_on_player_id"
  end

  create_table "monstertwos", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_monstertwos_on_player_id"
  end

  create_table "playercurses", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_playercurses_on_player_id"
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
    t.bigint "user_id", null: false
    t.index ["gameboard_id"], name: "index_players_on_gameboard_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
  end

  add_foreign_key "gameboards", "players", column: "current_player"
  add_foreign_key "graveyards", "gameboards"
  add_foreign_key "graveyards", "ingamedecks"
  add_foreign_key "handcards", "players"
  add_foreign_key "ingamedecks", "cards"
  add_foreign_key "ingamedecks", "gameboards"
  add_foreign_key "interceptcards", "gameboards"
  add_foreign_key "interceptcards", "ingamedecks"
  add_foreign_key "inventories", "players"
  add_foreign_key "monsterones", "players"
  add_foreign_key "monsterthrees", "players"
  add_foreign_key "monstertwos", "players"
  add_foreign_key "playercurses", "players"
  add_foreign_key "players", "gameboards"
  add_foreign_key "players", "users"
end
