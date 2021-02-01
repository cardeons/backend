# frozen_string_literal: true

json.extract! gameboard, :id, :current_state, :player_atk, :monster_atk, :asked_help, :success, :can_flee, :shared_reward, :created_at, :updated_at
json.url gameboard_url(gameboard, format: :json)
