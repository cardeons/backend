# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Monstercard, type: :model do
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
      element_modifier: 2,
      atk_points: 2,
      item_category: 'head',
      has_combination: false
    )
    u1 = User.create!(email: '1@1.at', password: '1', name: '1', password_confirmation: '1')
    gameboard_test = Gameboard.create!(current_state: 'lobby', player_atk: 5)
    player1 = Player.create(name: 'Gustav', gameboard: gameboard_test, user: u1)
    Handcard.create(player_id: player1.id)
    Monsterone.create(player: player1)
    ingamedeck1 = Ingamedeck.create!(gameboard: gameboard_test, card_id: catfish.id, cardable: player1.monsterone)
    ingamedeck2 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)
    params = { 'unique_monster_id'=>ingamedeck1.id, 'unique_equip_id'=>ingamedeck2.id, 'action'=>'equip_monster' }

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
      element_modifier: 2,
      atk_points: 2,
      item_category: 'head',
      has_combination: false
    )
    u1 = User.create!(email: '1@1.at', password: '1', name: '1', password_confirmation: '1')
    gameboard_test = Gameboard.create!(current_state: 'lobby', player_atk: 5)
    player1 = Player.create(name: 'Gustav', gameboard: gameboard_test, user: u1)
    Handcard.create(player_id: player1.id)
    Monsterone.create(player: player1)
    ingamedeck1 = Ingamedeck.create!(gameboard: gameboard_test, card_id: catfish.id, cardable: player1.monsterone)
    ingamedeck2 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)
    ingamedeck3 = Ingamedeck.create!(gameboard: gameboard_test, card_id: item1.id, cardable: player1.handcard)
    params = { 'unique_monster_id'=>ingamedeck1.id, 'unique_equip_id'=>ingamedeck2.id, 'action'=>'equip_monster' }
    params2 = { 'unique_monster_id'=>ingamedeck1.id, 'unique_equip_id'=>ingamedeck3.id, 'action'=>'equip_monster' }
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

    u1 = User.create!(email: '1@1.at', password: '1', name: '1', password_confirmation: '1')
    gameboard_test = Gameboard.create!(current_state: 'lobby', player_atk: 5)
    player1 = Player.create(name: 'Gustav', gameboard: gameboard_test, user: u1)
    Handcard.create(player_id: player1.id)
    Monsterone.create(player: player1)
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

    u1 = User.create!(email: '1@1.at', password: '1', name: '1', password_confirmation: '1')
    gameboard_test = Gameboard.create!(current_state: 'lobby', player_atk: 5)
    player1 = Player.create(name: 'Gustav', gameboard: gameboard_test, user: u1)
    Handcard.create(player_id: player1.id)
    Monsterone.create(player: player1)
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
      element_modifier: 2,
      atk_points: 2,
      item_category: 'head',
      has_combination: false
    )
    
    item2 = Itemcard.create!(
      title: 'The things to get things out of the toilet',
      description: '<p>Disgusting. If I was you, I would not touch it.</p>',
      image: '/item/poempel.png',
      action: 'plus_one',
      draw_chance: 14,
      element: 'fire',
      element_modifier: 2,
      atk_points: 2,
      item_category: 'hand_one',
      has_combination: false
    )
    item3 = Itemcard.create!(
      title: 'Hermes shoes',
      description: '<p>Damn, those are some nice shoes! Hopefully hermes does not mind you took them..</p>',
      image: '/item/shoes.png',
      action: 'plus_3',
      draw_chance: 5,
      element: 'earth',
      element_modifier: 3,
      atk_points: 4,
      item_category: 'shoes',
      has_combination: false
    )
    item4 = Itemcard.create!(
      title: 'Helmet of Doom',
      description: '<p>This is the helmet of doom</p>',
      image: '/item/helmet.png',
      action: 'plus_one',
      draw_chance: 13,
      element: 'fire',
      element_modifier: 2,
      atk_points: 2,
      item_category: 'hand_two',
      has_combination: false
    )
    
    item5 = Itemcard.create!(
      title: 'The things to get things out of the toilet',
      description: '<p>Disgusting. If I was you, I would not touch it.</p>',
      image: '/item/poempel.png',
      action: 'plus_one',
      draw_chance: 14,
      element: 'fire',
      element_modifier: 2,
      atk_points: 2,
      item_category: 'none',
      has_combination: false
    )
    item6 = Itemcard.create!(
      title: 'Hermes shoes',
      description: '<p>Damn, those are some nice shoes! Hopefully hermes does not mind you took them..</p>',
      image: '/item/shoes.png',
      action: 'plus_3',
      draw_chance: 5,
      element: 'earth',
      element_modifier: 3,
      atk_points: 4,
      item_category: 'back',
      has_combination: false
    )

    u1 = User.create!(email: '1@1.at', password: '1', name: '1', password_confirmation: '1')
    gameboard_test = Gameboard.create!(current_state: 'lobby', player_atk: 5)
    player1 = Player.create(name: 'Gustav', gameboard: gameboard_test, user: u1)
    Handcard.create(player_id: player1.id)
    Monsterone.create(player: player1)
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
end
