# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Itemcard, type: :model do
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
      title: 'The things to get things out of the toilet',
      description: '<p>Disgusting. If I was you, I would not touch it.</p>',
      image: '/item/poempel.png',
      action: 'plus_one',
      draw_chance: 14,
      bad_against: 'fire',
      bad_against_value: 3,
      good_against: 'water',
      good_against_value: 1,
      synergy_type: 'boar',
      synergy_value: 1,
      atk_points: 2,
      item_category: 'hand'
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

  it 'is valid without synergy' do
    subject.synergy_type = nil
    subject.synergy_value = nil

    expect(subject).to be_valid
  end

  it 'calculates synergies with ' do
    catfish = Monstercard.create!(
      title: 'Catfish',
      description: '<p>HA! You got catfished.</p>',
      image: '/monster/catfish.png',
      action: 'lose_level',
      draw_chance: 5,
      animal: 'catfish',
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
      synergy_type: 'catfish',
      synergy_value: 3,
      atk_points: 2,
      item_category: 'head'
    )

    expect(item1.calculate_synergy_value(catfish)).to eql(3)

    # wrong synergy type should return 0
    item1.update!(synergy_type: 'boar', synergy_value: 5)
    expect(item1.calculate_synergy_value(catfish)).to eql(0)
  end
end
