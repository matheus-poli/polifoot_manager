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

ActiveRecord::Schema[8.0].define(version: 2025_09_05_150432) do
  create_table "game_events", force: :cascade do |t|
    t.integer "minute"
    t.text "description"
    t.integer "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_events_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "status"
    t.integer "score_team_a"
    t.integer "score_team_b"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "possession_player_id"
    t.string "ball_zone"
    t.json "player_data", default: {}
    t.integer "current_minute"
    t.index ["possession_player_id"], name: "index_games_on_possession_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "team_name"
    t.string "tactic"
    t.boolean "ready"
    t.integer "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_token"
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["user_token"], name: "index_players_on_user_token"
  end

  add_foreign_key "game_events", "games"
  add_foreign_key "games", "players", column: "possession_player_id"
  add_foreign_key "players", "games"
end
