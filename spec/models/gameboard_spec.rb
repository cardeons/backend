# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gameboard, type: :model do
  fixtures :users, :players, :gameboards, :cards, :monsterones, :ingamedecks, :centercards

  before :each do
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
      bad_things: 'MyString',
      rewards_treasure: 'MyString',
      good_against_value: 1,
      bad_against_value: 1,
      atk_points: 1,
      item_category: 'MyString',
      level_amount: 1
    )

    srand(4)
  end

  ####### initialize_game_board #######
  it 'test gameboard should have 4 players' do
    # gameboard = gameboards(:gameboardFourPlayers)
    expect(players(:playerOne).gameboard.players.count).to eq 4
  end

  it 'player four with id 5 should be current player because he was the last to join' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    expect(gameboards(:gameboardFourPlayers).current_player).to eq players(:playerFour)
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

    centercard = (Gameboard.render_card_from_id(gameboards(:gameboardFourPlayers).centercard.ingamedeck.id) if gameboards(:gameboardFourPlayers).centercard.ingamedeck)
    gameboard_obj = {
      gameboard_id: gameboards(:gameboardFourPlayers).id,
      current_player: gameboards(:gameboardFourPlayers).current_player.id,
      center_card: centercard,
      interceptcards: [],
      player_interceptcards: [],
      player_atk: gameboards(:gameboardFourPlayers).player_atk,
      monster_atk: gameboards(:gameboardFourPlayers).monster_atk,
      success: gameboards(:gameboardFourPlayers).success,
      can_flee: gameboards(:gameboardFourPlayers).can_flee,
      rewards_treasure: gameboards(:gameboardFourPlayers).rewards_treasure,
      graveyard: [],
      shared_reward: gameboards(:gameboardFourPlayers).shared_reward,
      helping_player: gameboards(:gameboardFourPlayers).helping_player,
      current_state: 'ingame',
      intercept_timestamp: nil
    }
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    expect(Gameboard.render_gameboard(gameboards(:gameboardFourPlayers))).to eql(gameboard_obj)
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    # puts ending - starting
  end

  # only measure times
  it 'runs broadcast gameboard ' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    Gameboard.broadcast_game_board(gameboards(:gameboardFourPlayers))

    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    # puts ending - starting
  end

  it 'renders the right card from id' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    ingamedeck_id = gameboards(:gameboardFourPlayers).players.first.handcard.ingamedecks.first.id
    card_id = gameboards(:gameboardFourPlayers).players.first.handcard.ingamedecks.first.card_id

    card = Gameboard.render_card_from_id(ingamedeck_id)

    schema = { unique_card_id: ingamedeck_id, card_id: card_id }

    expect(card).to eql(schema)
  end

  # #get_next_player
  it 'chooses the right next player' do
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).initialize_game_board
    expect(Gameboard.get_next_player(gameboards(:gameboardFourPlayers))).to eql(gameboards(:gameboardFourPlayers).players.first)
  end

  it 'chooses the right next player after 4 times' do
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).initialize_game_board

    Gameboard.get_next_player(gameboards(:gameboardFourPlayers))
    Gameboard.get_next_player(gameboards(:gameboardFourPlayers))
    Gameboard.get_next_player(gameboards(:gameboardFourPlayers))

    expect(Gameboard.get_next_player(gameboards(:gameboardFourPlayers))).to eql(gameboards(:gameboardFourPlayers).players.last)
  end

  it 'current centercards get thrown to graveyard' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    # draw new centercard
    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    previous_centercard = gameboards(:gameboardFourPlayers).centercard.ingamedeck
    expect(previous_centercard.cardable_type).to eql('Centercard')

    # Draw another card now the old centercards should be moved to the graveyard
    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    # old card should now be moved to the graveyard
    expect(previous_centercard.reload.cardable_type).to eql('Graveyard')
    expect(gameboards(:gameboardFourPlayers).centercard.ingamedeck).to be_truthy
  end

  it 'gets new centercard' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    # create a previous centercard
    previous_centercard = gameboards(:gameboardFourPlayers).centercard.ingamedeck
    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    new_centercard = gameboards(:gameboardFourPlayers).centercard.ingamedeck

    expect(previous_centercard.reload.id).to_not eql(new_centercard.id)
  end

  # it 'flee returns right value in gameboard if it is successful or not' do
  #   gameboards(:gameboardFourPlayers).initialize_game_board
  #   gameboards(:gameboardFourPlayers).players.each(&:init_player)

  #   flee_result = Gameboard.flee(gameboards(:gameboardFourPlayers))

  #   expect(flee_result[:value] < 5).to be_truthy if flee_result[:flee] == false
  #   expect(flee_result[:value] >= 5).to be_truthy if flee_result[:flee] == true
  #   expect(gameboards(:gameboardFourPlayers).can_flee).to eql(flee_result[:flee])
  # end

  it 'flee returns right value in gameboard if it is successful or not' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard), cardable: gameboards(:gameboardFourPlayers).centercard)
    gameboards(:gameboardFourPlayers).current_player.update(level: 4)

    flee_result = Gameboard.flee(gameboards(:gameboardFourPlayers), User.where(player: gameboards(:gameboardFourPlayers).current_player))
    if flee_result[:flee]
      expect(flee_result[:value] >= 5).to be_truthy
      expect(gameboards(:gameboardFourPlayers).current_player.level).to eql(4)
    end
    expect(gameboards(:gameboardFourPlayers).can_flee).to eql(flee_result[:flee])
  end

  it 'attack' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    playerwin = Gameboard.attack(gameboards(:gameboardFourPlayers))

    # expect(playeratk.to(eql))
    expect(gameboards(:gameboardFourPlayers).success).to be_truthy if playerwin[:result]
    expect(gameboards(:gameboardFourPlayers).success).to be_falsy unless playerwin[:result]
  end

  it 'test if get_next_player deletes curse cards' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    player = gameboards(:gameboardFourPlayers).current_player
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard), cardable: player.playercurse)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard), cardable: player.playercurse)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard), cardable: player.playercurse)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard), cardable: player.playercurse)

    expect(player.playercurse.ingamedecks.count).to eql(4)
    Gameboard.get_next_player(gameboards(:gameboardFourPlayers))
    expect(player.playercurse.ingamedecks.count).to eql(0)
  end

  it 'test if get_next_player deletes curse cards but not sticky one' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    player = gameboards(:gameboardFourPlayers).current_player
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard), cardable: player.playercurse)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard5), cardable: player.playercurse)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard), cardable: player.playercurse)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard), cardable: player.playercurse)

    expect(player.playercurse.ingamedecks.count).to eql(4)
    Gameboard.get_next_player(gameboards(:gameboardFourPlayers))
    expect(player.playercurse.ingamedecks.count).to eql(1)
  end

  it 'element modifiers are calculated correct' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    player = gameboards(:gameboardFourPlayers).current_player

    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:firemonster), cardable: gameboards(:gameboardFourPlayers).centercard)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:watermonster), cardable: player.monsterone)

    expect(gameboards(:gameboardFourPlayers).calculate_element_modifiers).to eql(
      {
        modifier_player: -2,
        modifier_monster: 3
      }
    )

    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:earthmonster), cardable: player.monstertwo)

    expect(gameboards(:gameboardFourPlayers).calculate_element_modifiers).to eql(
      {
        modifier_player: 3,
        modifier_monster: 3
      }
    )

    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:earthmonster), cardable: player.monsterthree)

    expect(gameboards(:gameboardFourPlayers).calculate_element_modifiers).to eql(
      {
        modifier_player: 8,
        modifier_monster: 3
      }
    )

    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:watermonster), cardable: player.monsterone)
  end

  it 'element modifier is only counted once if playes has two of the same type' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    player = gameboards(:gameboardFourPlayers).current_player

    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:firemonster), cardable: gameboards(:gameboardFourPlayers).centercard)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:watermonster), cardable: player.monsterone)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:watermonster), cardable: player.monstertwo)

    expect(gameboards(:gameboardFourPlayers).calculate_element_modifiers).to eql(
      {
        modifier_player: -4,
        modifier_monster: 3
      }
    )
  end
end
