# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Monstercard, type: :model do
  fixtures :users, :players, :gameboards, :cards, :monsterones, :ingamedecks, :centercards

  before do
    # initialize connection with identifiers
    users(:userOne).player = players(:playerOne)
    users(:userTwo).player = players(:playerTwo)
    users(:userThree).player = players(:playerThree)
    users(:userFour).player = players(:playerFour)

    players(:playerOne).monsterone = monsterones(:three)
  end

  it 'player gains attack if card is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player

    buff = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:buffcard), cardable: current_player.playercurse)
    gameboards(:gameboardFourPlayers).update(player_atk: 5)
    Buffcard.activate(buff, current_player, gameboards(:gameboardFourPlayers))
    expect(gameboards(:gameboardFourPlayers).reload.player_atk).to eql(10)
  end

  it 'monster loses attack if card is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player

    buff = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:buffcard2), cardable: current_player.playercurse)
    gameboards(:gameboardFourPlayers).update(monster_atk: 15)
    Buffcard.activate(buff, current_player, gameboards(:gameboardFourPlayers))
    expect(gameboards(:gameboardFourPlayers).reload.monster_atk).to eql(10)
  end

  it 'player can flee if card is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player

    buff = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:buffcard3), cardable: current_player.playercurse)
    expect(gameboards(:gameboardFourPlayers).can_flee).to eql(false)
    Buffcard.activate(buff, current_player, gameboards(:gameboardFourPlayers))
    expect(gameboards(:gameboardFourPlayers).can_flee).to eql(true)
  end

  it 'player can flee if card is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player

    buff = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:buffcard6), cardable: current_player.playercurse)
    expect(gameboards(:gameboardFourPlayers).can_flee).to eql(false)
    Buffcard.activate(buff, current_player, gameboards(:gameboardFourPlayers))
    expect(gameboards(:gameboardFourPlayers).can_flee).to eql(true)
  end

  it 'player draws handcards if card is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player

    buff = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:buffcard4), cardable: current_player.playercurse)
    expect(current_player.handcard.ingamedecks.count).to eql(5)
    Buffcard.activate(buff, current_player, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.handcard.ingamedecks.count).to eql(7)
  end

  it 'player gets help if card is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    gameboards(:gameboardFourPlayers).update(helping_player: 3, helping_player_atk: 0)

    buff = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:buffcard5), cardable: current_player.playercurse)
    expect(gameboards(:gameboardFourPlayers).helping_player_atk).to eql(0)
    Buffcard.activate(buff, current_player, gameboards(:gameboardFourPlayers))
    expect(gameboards(:gameboardFourPlayers).reload.helping_player_atk).to eql(1)
  end
end
