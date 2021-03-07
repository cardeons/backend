# frozen_string_literal: true

class GameboardFrontend
  def initialize(id, current_player, current_player_name, current_state)
    # Instance variables
    @id = id
    @current_player = current_player
    @current_player_name = current_player_name
    @current_state = current_state
    @center_card = nil
    @interceptcards = []
    @player_atk = 0
    @monster_atk = 0
    @success = false
    @can_flee = false
    @rewards_treasure = 0
  end

  attr_reader :id, :players
  attr_accessor :current_state, :current_player, :current_player_name, :center_card, :interceptcards, :player_atk, :monster_atk, :success, :can_flee, :rewards_treasure
end
