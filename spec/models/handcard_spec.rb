# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Handcard, type: :model do
  subject do
    described_class.create(
      player: Player.create(name: 'Alberto', gameboard: Gameboard.create!(current_state: 'lobby', player_atk: 5),
                            user: User.create!(email: '1@1.at', password: '1', name: '1', password_confirmation: '1'))
    )
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a player' do
    subject.player = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a unique id' do
    player = Player.create(name: 'Alberto', gameboard: Gameboard.create!(current_state: 'lobby', player_atk: 5),
                           user: User.create!(email: '1@1.at', password: '1', name: '1', password_confirmation: '1'))
    handcard = described_class.create(
      player: player
    )
    handcard2 = described_class.create(
      player: player
    )

    expect(handcard2).to_not be_valid
  end

  it 'draws five random handcards' do
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

    item1 = Itemcard.create!(
      title: 'Helmet of Doom',
      description: '<p>This is the helmet of doom</p>',
      image: '/item/helmet.png',
      action: 'plus_one',
      draw_chance: 13,
      element: 'fire',
      atk_points: 2,
      item_category: 'head',
      has_combination: false
    )

    Handcard.draw_handcards(subject.player.id, subject.player.gameboard)

    expect(subject.player.handcard.cards.count == 5).to be_truthy
  end
end
