# frozen_string_literal: true

class GameboardFrontend
  def initialize(id, current_player)
    # Instance variables
    @id = id
    @current_player = current_player
    @center_card = nil
    @interceptcards = []
    @player_atk = 0
    @monster_atk = 0
    @success = false
    @can_flee = false
    @rewards_treasure = 0
  end

  attr_reader :id, :players
  attr_accessor :current_player, :center_card, :interceptcards, :player_atk, :monster_atk, :success, :can_flee, :rewards_treasure
end
