# frozen_string_literal: true

require 'rails_helper'
require 'pp'

RSpec.describe Gameboard, type: :model do
  fixtures :users, :players, :gameboards, :cards, :monsterones, :ingamedecks, :centercards

  before do
    # initialize connection with identifiers
    users(:userOne).player = players(:playerOne)
    users(:userTwo).player = players(:playerTwo)
    users(:userThree).player = players(:playerThree)
    users(:userFour).player = players(:playerFour)

    players(:playerOne).monsterone = monsterones(:three)
    # players(:playerOne).monsterone.cards = ingamedecks(:four)
    # gameboards(:gameboardFourPlayers).ingamedeck = ingamedecks(:four), ingamedecks(:three)

    # players(:playerOne).monsterone.cards = ingamedecks(:four)

    Itemcard.create(
      id: 5555,
      title: 'Itemcard',
      description: 'Beschreibung',
      image: 'MyString',
      action: 'MyString',
      draw_chance: 1,
      level: 1,
      element: 'MyString',
      bad_things: 'MyString',
      rewards_treasure: 'MyString',
      good_against: 'MyString',
      bad_against: 'MyString',
      good_against_value: 1,
      bad_against_value: 1,
      element_modifier: 1,
      atk_points: 1,
      item_category: 'MyString',
      has_combination: 1,
      level_amount: 1
    )
  end

  ####### initialize_game_board #######
  it 'test gameboard should have 4 players' do
    # gameboard = gameboards(:gameboardFourPlayers)
    expect(players(:playerOne).gameboard.players.count).to eq 4
  end

  it 'player four with id 5 should be current player because he was the last to join' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    expect(gameboards(:gameboardFourPlayers).current_player).to eq 5
  end

  it 'gameboard should have a graveyard' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    expect(Graveyard.find_by('gameboard_id = ?', gameboards(:gameboardFourPlayers).id)).to be_present
  end

  it 'gameboard should have a centercard' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    expect(Centercard.find_by('gameboard_id = ?', gameboards(:gameboardFourPlayers).id)).to be_present
  end

  it 'players should have handcards' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    expect(players(:playerOne).handcard).to be_present
    expect(players(:playerTwo).handcard).to be_present
    expect(players(:playerThree).handcard).to be_present
    expect(players(:playerFour).handcard).to be_present
  end

  # TODO: test if every player has 5 cards after draw_handcards!
  it 'all players should have 5 handcards' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    expect(players(:playerOne).handcard.cards.count).to eq 5
    expect(players(:playerTwo).handcard.cards.count).to eq 5
    expect(players(:playerThree).handcard.cards.count).to eq 5
    expect(players(:playerFour).handcard.cards.count).to eq 5
  end

  ####### renderUserMonsters #######
  # TODO: add test?
  it 'selects the right monsterslot' do
    # pp gameboards(:gameboardFourPlayers).ingamedeck
    # players(:playerOne).mmonsterone =
    # result = Gameboard.renderUserMonsters(players(:playerOne), 'Monsterone')
    # expect(result).to be_truthy
  end

  it 'render gameboard' do
    gameboards(:gameboardFourPlayers).initialize_game_board

    centercard = (Gameboard.render_card_from_id(gameboards(:gameboardFourPlayers).centercard.ingamedecks.first.id) if gameboards(:gameboardFourPlayers).centercard.ingamedecks.any?)
    gameboard_obj = {
      gameboard_id: gameboards(:gameboardFourPlayers).id,
      current_player: gameboards(:gameboardFourPlayers).current_player,
      center_card: centercard,
      interceptcards: [],
      player_atk: gameboards(:gameboardFourPlayers).player_atk,
      monster_atk: gameboards(:gameboardFourPlayers).monster_atk,
      success: gameboards(:gameboardFourPlayers).success,
      can_flee: gameboards(:gameboardFourPlayers).can_flee,
      rewards_treasure: gameboards(:gameboardFourPlayers).rewards_treasure
    }
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    expect(Gameboard.render_gameboard(gameboards(:gameboardFourPlayers))).to eql(gameboard_obj)
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts ending - starting
  end

  it 'runs broadcast gameboard ' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    Gameboard.broadcast_game_board(gameboards(:gameboardFourPlayers))

    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts ending - starting
  end
end
