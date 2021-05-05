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

  subject do
    described_class.new(
      title: 'Sir Bear',
      description: '<p>A very serious bear with a beard.</p>',
      image: '/monster/bear.png',
      action: 'lose_item_head',
      draw_chance: 10,
      level: 3,
      element: 'earth',
      bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your headpiece.</p>',
      rewards_treasure: 1,
      good_against: 'fire',
      bad_against: 'air',
      good_against_value: 3,
      bad_against_value: 1,
      atk_points: 6,
      level_amount: 1
    )
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a title' do
    subject.title = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a description' do
    subject.description = nil
    expect(subject).to_not be_valid
  end

  it 'equips monster' do
    catfish = Monstercard.create!(
      title: 'Catfish',
      description: '<p>HA! You got catfished.</p>',
      image: '/monster/catfish.png',
      action: 'lose_level',
      draw_chance: 5,
      level: 10,
      element: 'water',
      bad_things: '<p><b>Bad things:</b>Getting catfished, really? You should know better. Lose one level.</p>',
      rewards_treasure: 2,
      good_against: 'fire',
      bad_against: 'earth',
      good_against_value: 3,
      bad_against_value: 1,
      atk_points: 14,
      level_amount: 2
    )
    item1 = Itemcard.create!(
      title: 'Helmet of Doom',
      description: '<p>This is the helmet of doom</p>',
      image: '/item/helmet.png',
      action: 'plus_one',
      draw_chance: 13,
      element: 'fire',
      atk_points: 2,
      item_category: 'head'
    )
    gameboard_test = gameboards(:gameboardFourPlayers)
    player1 = players(:playerOne)
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).update(current_player: player1)

    ingamedeck1 = Ingamedeck.create!(gameboard: gameboard_test, card_id: catfish.id, cardable: player1.monsterone)
    ingamedeck2 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)
    params = { 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck2.id, 'action' => 'equip_monster' }

    result = Monstercard.equip_monster(params, player1)
    expect(result == { type: 'GAMEBOARD_UPDATE', message: 'Successfully equipped.' }).to be_truthy
  end

  it 'does not equip monster with same item category' do
    catfish = Monstercard.create!(
      title: 'Catfish',
      description: '<p>HA! You got catfished.</p>',
      image: '/monster/catfish.png',
      action: 'lose_level',
      draw_chance: 5,
      level: 10,
      element: 'water',
      bad_things: '<p><b>Bad things:</b>Getting catfished, really? You should know better. Lose one level.</p>',
      rewards_treasure: 2,
      good_against: 'fire',
      bad_against: 'earth',
      good_against_value: 3,
      bad_against_value: 1,
      atk_points: 14,
      level_amount: 2
    )
    item1 = Itemcard.create!(
      title: 'Helmet of Doom',
      description: '<p>This is the helmet of doom</p>',
      image: '/item/helmet.png',
      action: 'plus_one',
      draw_chance: 13,
      element: 'fire',
      atk_points: 2,
      item_category: 'head'
    )
    gameboard_test = gameboards(:gameboardFourPlayers)
    player1 = players(:playerOne)
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).update(current_player: player1)

    ingamedeck1 = Ingamedeck.create!(gameboard: gameboard_test, card_id: catfish.id, cardable: player1.monsterone)
    ingamedeck2 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)
    ingamedeck3 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)
    params = { 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck2.id, 'action' => 'equip_monster' }
    params2 = { 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck3.id, 'action' => 'equip_monster' }
    result = Monstercard.equip_monster(params, player1)
    result2 = Monstercard.equip_monster(params2, player1)
    expect(result2 == { type: 'ERROR', message: 'You already have this type of item on your monster! (head)' }).to be_truthy
  end

  it 'throws error if no card to equip' do
    catfish = Monstercard.create!(
      title: 'Catfish',
      description: '<p>HA! You got catfished.</p>',
      image: '/monster/catfish.png',
      action: 'lose_level',
      draw_chance: 5,
      level: 10,
      element: 'water',
      bad_things: '<p><b>Bad things:</b>Getting catfished, really? You should know better. Lose one level.</p>',
      rewards_treasure: 2,
      good_against: 'fire',
      bad_against: 'earth',
      good_against_value: 3,
      bad_against_value: 1,
      atk_points: 14,
      level_amount: 2
    )

    gameboard_test = gameboards(:gameboardFourPlayers)
    player1 = players(:playerOne)
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).update(current_player: player1)

    ingamedeck1 = Ingamedeck.create!(gameboard: gameboard_test, card_id: catfish.id, cardable: player1.monsterone)

    params = { 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => 303, 'action' => 'equip_monster' }
    result = Monstercard.equip_monster(params, player1)
    expect(result == { type: 'ERROR', message: 'Card not found. Something went wrong.' }).to be_truthy
  end

  it 'does not equip monster with a card thats not an item' do
    catfish = Monstercard.create!(
      title: 'Catfish',
      description: '<p>HA! You got catfished.</p>',
      image: '/monster/catfish.png',
      action: 'lose_level',
      draw_chance: 5,
      level: 10,
      element: 'water',
      bad_things: '<p><b>Bad things:</b>Getting catfished, really? You should know better. Lose one level.</p>',
      rewards_treasure: 2,
      good_against: 'fire',
      bad_against: 'earth',
      good_against_value: 3,
      bad_against_value: 1,
      atk_points: 14,
      level_amount: 2
    )
    curse = Cursecard.create!(
      title: 'very bad curse',
      description: '<p>This curse is very bad.</p><p> Actually, it is so bad that this curse will stick to you and weaken your fighting ability as long as you do not find a way to remove it</p>',
      image: '/',
      action: 'lose_atk_points',
      draw_chance: 4,
      atk_points: -1
    )

    gameboard_test = gameboards(:gameboardFourPlayers)
    player1 = players(:playerOne)
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).update(current_player: player1)

    ingamedeck1 = Ingamedeck.create!(gameboard: gameboard_test, card_id: catfish.id, cardable: player1.monsterone)
    ingamedeck2 = Ingamedeck.create!(gameboard: gameboard_test, card_id: curse.id, cardable: player1.handcard)

    params = { 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck2.id, 'action' => 'equip_monster' }
    result = Monstercard.equip_monster(params, player1)
    expect(result == { type: 'ERROR', message: "Sorry, you can't put anything on your monster that is not an item!" }).to be_truthy
  end
  it 'does not equip monster with more than 5 items' do
    catfish = Monstercard.create!(
      title: 'Catfish',
      description: '<p>HA! You got catfished.</p>',
      image: '/monster/catfish.png',
      action: 'lose_level',
      draw_chance: 5,
      level: 10,
      element: 'water',
      bad_things: '<p><b>Bad things:</b>Getting catfished, really? You should know better. Lose one level.</p>',
      rewards_treasure: 2,
      good_against: 'fire',
      bad_against: 'earth',
      good_against_value: 3,
      bad_against_value: 1,
      atk_points: 14,
      level_amount: 2
    )
    item1 = Itemcard.create!(
      title: 'Helmet of Doom',
      description: '<p>This is the helmet of doom</p>',
      image: '/item/helmet.png',
      action: 'plus_one',
      draw_chance: 13,
      element: 'fire',
      atk_points: 2,
      item_category: 'head'
    )

    item2 = Itemcard.create!(
      title: 'The things to get things out of the toilet',
      description: '<p>Disgusting. If I was you, I would not touch it.</p>',
      image: '/item/poempel.png',
      action: 'plus_one',
      draw_chance: 14,
      element: 'fire',
      atk_points: 2,
      item_category: 'hand_one'
    )
    item3 = Itemcard.create!(
      title: 'Hermes shoes',
      description: '<p>Damn, those are some nice shoes! Hopefully hermes does not mind you took them..</p>',
      image: '/item/shoes.png',
      action: 'plus_3',
      draw_chance: 5,
      element: 'earth',
      atk_points: 4,
      item_category: 'shoes'
    )
    item4 = Itemcard.create!(
      title: 'Helmet of Doom',
      description: '<p>This is the helmet of doom</p>',
      image: '/item/helmet.png',
      action: 'plus_one',
      draw_chance: 13,
      element: 'fire',
      atk_points: 2,
      item_category: 'hand_two'
    )

    item5 = Itemcard.create!(
      title: 'The things to get things out of the toilet',
      description: '<p>Disgusting. If I was you, I would not touch it.</p>',
      image: '/item/poempel.png',
      action: 'plus_one',
      draw_chance: 14,
      element: 'fire',
      atk_points: 2,
      item_category: 'none'
    )
    item6 = Itemcard.create!(
      title: 'Hermes shoes',
      description: '<p>Damn, those are some nice shoes! Hopefully hermes does not mind you took them..</p>',
      image: '/item/shoes.png',
      action: 'plus_3',
      draw_chance: 5,
      element: 'earth',
      atk_points: 4,
      item_category: 'back'
    )

    gameboard_test = gameboards(:gameboardFourPlayers)
    player1 = players(:playerOne)
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).update(current_player: player1)

    ingamedeck1 = Ingamedeck.create!(gameboard: gameboard_test, card_id: catfish.id, cardable: player1.monsterone)
    ingamedeck2 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)
    ingamedeck3 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item2.id, cardable: player1.handcard)
    ingamedeck4 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item3.id, cardable: player1.handcard)
    ingamedeck5 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item4.id, cardable: player1.handcard)
    ingamedeck6 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item5.id, cardable: player1.handcard)
    ingamedeck7 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item6.id, cardable: player1.handcard)

    Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck2.id, 'action' => 'equip_monster' }, player1)
    Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck3.id, 'action' => 'equip_monster' }, player1)
    Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck4.id, 'action' => 'equip_monster' }, player1)
    Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck5.id, 'action' => 'equip_monster' }, player1)
    Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck6.id, 'action' => 'equip_monster' }, player1)

    params = { 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck7.id, 'action' => 'equip_monster' }
    result = Monstercard.equip_monster(params, player1)
    expect(result == { type: 'ERROR', message: "You can't put any more items on this monster." }).to be_truthy
  end

  it 'lose one level if monster is winning' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    current_player.update(level: 3)
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard), cardable: current_player.playercurse)

    expect(current_player.level).to eql(3)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.level).to eql(2)
  end

  it 'lose all levels if monster is winning' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    current_player.update(level: 3)
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard2), cardable: current_player.playercurse)

    expect(current_player.level).to eql(3)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.level).to eql(1)
  end

  it 'lose 1 handcard if monster is winning' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard3), cardable: current_player.playercurse)

    expect(current_player.handcard.ingamedecks.count).to eql(5)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.handcard.ingamedecks.count).to eql(4)
  end

  it 'lose 1 hand item if monster is winning' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.monstertwo)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:itemcard4), cardable: current_player.monstertwo)
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.playercurse)

    expect(current_player.monstertwo.ingamedecks.count).to eql(2)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.monstertwo.ingamedecks.count).to eql(1)
  end

  it 'lose 1 hand item if monster is winning' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.monsterone)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:itemcard4), cardable: current_player.monsterone)
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.playercurse)

    expect(current_player.monsterone.ingamedecks.count).to eql(2)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.monsterone.ingamedecks.count).to eql(1)
  end

  it 'lose 0 hand item if none available and monster is winning' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.monstertwo)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:itemcard2), cardable: current_player.monstertwo)
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.playercurse)

    expect(current_player.monstertwo.ingamedecks.count).to eql(2)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.monstertwo.ingamedecks.count).to eql(2)
  end

  it 'lose 1 head item if monster is winning' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.monstertwo)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:itemcard2), cardable: current_player.monstertwo)
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard7), cardable: current_player.playercurse)

    expect(current_player.monstertwo.ingamedecks.count).to eql(2)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.monstertwo.ingamedecks.count).to eql(1)
  end

  it 'lose 1 shoes item if monster is winning' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.monstertwo)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:itemcard3), cardable: current_player.monstertwo)
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard8), cardable: current_player.playercurse)

    expect(current_player.monstertwo.ingamedecks.count).to eql(2)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.monstertwo.ingamedecks.count).to eql(1)
  end

  it 'lose 1 item if monster is winning' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: current_player.monstertwo)
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:itemcard3), cardable: current_player.monstertwo)
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard6), cardable: current_player.playercurse)

    expect(current_player.monstertwo.ingamedecks.count).to eql(2)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.monstertwo.ingamedecks.count).to eql(1)
  end

  it 'lose 1 handcard to lowest level player if monster is winning, everyone has the same level' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard5), cardable: current_player.playercurse)

    expect(current_player.handcard.ingamedecks.count).to eql(5)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.handcard.ingamedecks.count).to eql(4)
  end

  it 'lose 0 handcard to lowest level player if monster is winning, if you are the lowest level' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    gameboards(:gameboardFourPlayers).players.each do |player|
      player.update(level: 4)
    end

    current_player = gameboards(:gameboardFourPlayers).current_player
    current_player.update(level: 1)
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard5), cardable: current_player.playercurse)

    expect(current_player.handcard.ingamedecks.count).to eql(5)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    gameboards(:gameboardFourPlayers).players.each do |player|
      expect(player.reload.handcard.ingamedecks.count).to eql(5)
    end
  end

  it 'lose 1 handcard to lowest level player if monster is winning, if you are the highest level' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    current_player.update(level: 4)
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard5), cardable: current_player.playercurse)

    expect(current_player.handcard.ingamedecks.count).to eql(5)
    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.handcard.ingamedecks.count).to eql(4)
  end

  it 'get cursed if monster is winning' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = gameboards(:gameboardFourPlayers).current_player
    monster = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard4), cardable: current_player.handcard)

    Monstercard.bad_things(monster, gameboards(:gameboardFourPlayers))
    expect(current_player.reload.playercurse.ingamedecks.count).to eql(1)
  end

  it 'monster can have two hand items eqiupped' do
    catfish = Monstercard.create!(
      title: 'Catfish',
      description: '<p>HA! You got catfished.</p>',
      image: '/monster/catfish.png',
      action: 'lose_level',
      draw_chance: 5,
      level: 10,
      element: 'water',
      bad_things: '<p><b>Bad things:</b>Getting catfished, really? You should know better. Lose one level.</p>',
      rewards_treasure: 2,
      good_against: 'fire',
      bad_against: 'earth',
      good_against_value: 3,
      bad_against_value: 1,
      atk_points: 14,
      level_amount: 2
    )

    item1 = Itemcard.create!(
      title: 'The things to get things out of the toilet',
      description: '<p>Disgusting. If I was you, I would not touch it.</p>',
      image: '/item/poempel.png',
      action: 'plus_one',
      draw_chance: 14,
      element: 'fire',
      atk_points: 2,
      item_category: 'hand'
    )

    gameboard_test = gameboards(:gameboardFourPlayers)
    player1 = players(:playerOne)
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).update(current_player: player1)

    ingamedeck1 = Ingamedeck.create!(gameboard: gameboard_test, card_id: catfish.id, cardable: player1.monsterone)
    ingamedeck2 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)
    ingamedeck3 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)

    equip_one = Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck2.id, 'action' => 'equip_monster' }, player1)
    expect(equip_one == { type: 'GAMEBOARD_UPDATE', message: 'Successfully equipped.' }).to be_truthy

    equip_two = Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck3.id, 'action' => 'equip_monster' }, player1)
    expect(equip_two == { type: 'GAMEBOARD_UPDATE', message: 'Successfully equipped.' }).to be_truthy
  end
  it 'attack points are calculated correctly' do
    catfish = Monstercard.create!(
      title: 'Catfish',
      description: '<p>HA! You got catfished.</p>',
      image: '/monster/catfish.png',
      action: 'lose_level',
      draw_chance: 5,
      level: 10,
      element: 'water',
      bad_things: '<p><b>Bad things:</b>Getting catfished, really? You should know better. Lose one level.</p>',
      rewards_treasure: 2,
      good_against: 'fire',
      bad_against: 'earth',
      good_against_value: 3,
      bad_against_value: 1,
      atk_points: 14,
      level_amount: 2
    )

    item1 = Itemcard.create!(
      title: 'The things to get things out of the toilet',
      description: '<p>Disgusting. If I was you, I would not touch it.</p>',
      image: '/item/poempel.png',
      action: 'plus_one',
      draw_chance: 14,
      element: 'fire',
      atk_points: 2,
      item_category: 'hand'
    )

    gameboard_test = gameboards(:gameboardFourPlayers)
    player1 = players(:playerOne)
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).update(current_player: player1)

    ingamedeck1 = Ingamedeck.create!(gameboard: gameboard_test, card_id: catfish.id, cardable: player1.monsterone)
    ingamedeck2 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)
    ingamedeck3 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)

    equip_one = Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck2.id, 'action' => 'equip_monster' }, player1)
    ## attack must be 4 - monster has 14 atk but should be calculated as 1, item 2, player 1
    expect(player1.reload.attack).to eql(4)

    equip_two = Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck3.id, 'action' => 'equip_monster' }, player1)
    ## attack must be 6 - monster has 14 atk but should be calculated as 1, item 2+2, player 1
    expect(player1.attack).to eql(6)
  end

  it 'attack points are calculated correctly with synergies on items and items and items and monster' do
    catfish = Monstercard.create!(
      title: 'Catfish',
      description: '<p>HA! You got catfished.</p>',
      image: '/monster/catfish.png',
      action: 'lose_level',
      animal: 'catfish',
      draw_chance: 5,
      level: 10,
      element: 'water',
      bad_things: '<p><b>Bad things:</b>Getting catfished, really? You should know better. Lose one level.</p>',
      rewards_treasure: 2,
      good_against: 'fire',
      bad_against: 'earth',
      good_against_value: 3,
      bad_against_value: 1,
      atk_points: 14,
      level_amount: 2
    )

    item1 = Itemcard.create!(
      title: 'The things to get things out of the toilet',
      description: '<p>Disgusting. If I was you, I would not touch it.</p>',
      image: '/item/poempel.png',
      action: 'plus_one',
      draw_chance: 14,
      element: 'fire',
      atk_points: 2,
      item_category: 'hand',
      synergy_type: 'pizza',
      synergy_value: 5
    )

    u1 = User.create!(email: '1@1.at', password: '1', name: '1', password_confirmation: '1')
    gameboard_test = Gameboard.create!(current_state: 'lobby', player_atk: 5)
    player1 = Player.create(name: 'Gustav', gameboard: gameboard_test, user: u1)

    Handcard.create(player_id: player1.id)
    Monsterone.create(player: player1)
    ingamedeck1 = Ingamedeck.create!(gameboard: gameboard_test, card_id: catfish.id, cardable: player1.monsterone)
    ingamedeck2 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)

    Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck2.id, 'action' => 'equip_monster' }, player1)
    ## attack must be 4 - monster has 14 atk but should be calculated as 1, item 2, player 1
    expect(player1.attack).to eql(4)

    item2 = Itemcard.create!(
      title: 'Item that has pizza as animal',
      description: '<p>meh</p>',
      image: '/item/poempel.png',
      action: 'plus_one',
      draw_chance: 14,
      synergy_type: 'catfish',
      synergy_value: 3,
      atk_points: 2,
      item_category: 'foot',
      animal: 'pizza'
    )
    ingamedeck4 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item2.id, cardable: player1.handcard)

    Monstercard.equip_monster({ 'unique_monster_id' => ingamedeck1.id, 'unique_equip_id' => ingamedeck4.id, 'action' => 'equip_monster' }, player1)
    # Player is level 1
    # Item1 gives 2
    # Monster gives 1
    # Item2 gives 2

    # synergy item1 und item2 gives 5
    # synergy monster and item2 gives 3
    expect(player1.attack).to eql(14)
  end
end
