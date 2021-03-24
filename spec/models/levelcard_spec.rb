# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Levelcard, type: :model do
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
      title: 'Levelcard',
      description: 'This is a levelcard',
      image: 'path to image',
      action: 'level_up',
      level_amount: 2,
      type: 'Levelcard'
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

  it 'is not valid without an action' do
    subject.action = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a level amount' do
    subject.level_amount = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a type' do
    subject.type = nil
    expect(subject).to_not be_valid
  end

  it 'gain 1 level if card is activated' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    levelcard = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: subject, cardable: current_player.playercurse)

    expect(current_player.level).to eql(1)
    Levelcard.activate(levelcard, current_player)
    expect(current_player.level).to eql(2)
  end

  it 'gain 0 level if card is activated and level is 4' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    current_player = Player.find(gameboards(:gameboardFourPlayers).current_player)
    current_player.update(level: 4)
    levelcard = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: subject, cardable: current_player.playercurse)

    expect(current_player.level).to eql(4)
    Levelcard.activate(levelcard, current_player)
    expect(current_player.level).to eql(4)
  end
end
