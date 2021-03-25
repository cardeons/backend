# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlayerChannel, type: :channel do
  fixtures :users, :players, :gameboards, :centercards, :cards, :graveyards

  before do
    # initialize connection with identifiers
    users(:usernorbert).player = players(:singleplayer)
    users(:usernorbert).player.init_player
    stub_connection current_user: users(:usernorbert)
    # srand sets the seed for the rnd generator of rails => rails returns the same value if srand is sets
    srand(1)
  end

  it 'test if flee broadcasts to all players' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first

    stub_connection current_user: users(:one)
    subscribe

    expect do
      perform('broadcast_all_playerhandcards', { gameboard: gameboards(:gameboardFourPlayers) })
    end.to have_broadcasted_to(connection.current_user)
      .with(
        hash_including(type: 'HANDCARD_UPDATE')
      ).exactly(:once)
  end
end
