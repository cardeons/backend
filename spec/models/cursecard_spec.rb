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

  it 'lose one level if curse is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    current_player.update(level: 3)
    curse = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard2), cardable: current_player.playercurse)

    expect(current_player.level).to eql(3)
    Cursecard.activate(curse, current_player, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.level).to eql(2)
    expect(curse.cardable).to eql(gameboards(:gameboardFourPlayers).graveyard)
  end

  it 'lose 1 hand item if curse is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.monstertwo)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:itemcard4), cardable: current_player.monstertwo)
    curse = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard4), cardable: current_player.playercurse)

    expect(current_player.monstertwo.ingamedecks.count).to eql(2)
    Cursecard.activate(curse, current_player, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.monstertwo.ingamedecks.count).to eql(1)
    expect(curse.cardable).to eql(gameboards(:gameboardFourPlayers).graveyard)
  end

  it 'lose 1 hand item if curse is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.monsterone)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:itemcard4), cardable: current_player.monsterone)
    curse = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard4), cardable: current_player.playercurse)

    expect(current_player.monsterone.ingamedecks.count).to eql(2)
    Cursecard.activate(curse, current_player, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.monsterone.ingamedecks.count).to eql(1)
    expect(curse.cardable).to eql(gameboards(:gameboardFourPlayers).graveyard)
  end

  it 'lose 0 hand item if none available and curse is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.monstertwo)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:itemcard2), cardable: current_player.monstertwo)
    curse = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard4), cardable: current_player.playercurse)

    expect(current_player.monstertwo.ingamedecks.count).to eql(2)
    Cursecard.activate(curse, current_player, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.monstertwo.ingamedecks.count).to eql(2)
    expect(curse.cardable).to eql(gameboards(:gameboardFourPlayers).graveyard)
  end

  it 'lose 1 head item if curse is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.monstertwo)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:itemcard2), cardable: current_player.monstertwo)
    curse = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard3), cardable: current_player.playercurse)

    expect(current_player.monstertwo.ingamedecks.count).to eql(2)
    Cursecard.activate(curse, current_player, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.monstertwo.ingamedecks.count).to eql(1)
    expect(curse.cardable).to eql(gameboards(:gameboardFourPlayers).graveyard)
  end

  it 'lose atk_points if curse is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    curse = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard5), cardable: current_player.playercurse)

    expect(current_player.attack).to eql(1)
    curse_obj = Cursecard.activate(curse, current_player, gameboards(:gameboardFourPlayers), 1)
    expect(curse_obj[:playeratk]).to eql(0)
  end

  it 'set asked_help to true if curse is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    curse = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard), cardable: current_player.playercurse)

    expect(gameboards(:gameboardFourPlayers).asked_help).to eql(false)
    Cursecard.activate(curse, current_player, gameboards(:gameboardFourPlayers))
    expect(gameboards(:gameboardFourPlayers).asked_help).to eql(true)
  end

  it 'set rewards *2 and player_atk *2 to true if curse is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    curse = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard7), cardable: current_player.playercurse)
    gameboards(:gameboardFourPlayers).update(player_atk: 2, rewards_treasure: 2)

    expect(gameboards(:gameboardFourPlayers).player_atk).to eql(2)
    expect(gameboards(:gameboardFourPlayers).rewards_treasure).to eql(2)
    curse_obj = Cursecard.activate(curse, current_player, gameboards(:gameboardFourPlayers), 2)
    expect(curse_obj[:playeratk]).to eql(4)
    expect(gameboards(:gameboardFourPlayers).rewards_treasure).to eql(4)
  end

  it 'set minus atk next fight if curse is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).update(player_atk: 2, rewards_treasure: 2)
    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    curse = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard6), cardable: current_player.playercurse)

    expect(gameboards(:gameboardFourPlayers).player_atk).to eql(2)
    curse_obj = Cursecard.activate(curse, current_player, gameboards(:gameboardFourPlayers), 2)
    pp curse_obj
    pp curse_obj[:playeratk]
    expect(curse_obj[:playeratk]).to eql(1)
  end
end
