# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interceptcard, type: :model do
  fixtures :gameboards, :players, :users, :cards

  subject do
    described_class.create(
      gameboard: gameboards(:gameboardFourPlayers)
    )
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a gameboard' do
    subject.gameboard = nil
    expect(subject).to_not be_valid
  end

  it 'adds card with ingamedeck_id' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    player = gameboards(:gameboardFourPlayers).players.first
    player.handcard.ingamedecks.create(card: cards(:buffcard), gameboard: gameboards(:gameboardFourPlayers))
    # player should now have a buffcard
    ingamedeck_card = player.handcard.ingamedecks.find_by!('card_id=?', cards(:buffcard).id)
    expect(ingamedeck_card).to be_truthy

    expect(gameboards(:gameboardFourPlayers).interceptcard.ingamedecks.find_by('id=?', ingamedeck_card.id)).to be_falsy

    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    gameboards(:gameboardFourPlayers).interceptcard.add_card_with_ingamedeck_id(ingamedeck_card.id)

    expect(player.handcard.ingamedecks.find_by('id=?', ingamedeck_card.id)).to be_falsy
    expect(gameboards(:gameboardFourPlayers).interceptcard.ingamedecks.find_by('id=?', ingamedeck_card.id)).to be_truthy
  end

  it 'interceptcard should increase monster dmg' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    player = gameboards(:gameboardFourPlayers).players.first
    player.handcard.ingamedecks.create(card: cards(:buffcard), gameboard: gameboards(:gameboardFourPlayers))
    # player should now have a buffcard
    ingamedeck_card = player.handcard.ingamedecks.find_by!('card_id=?', cards(:buffcard).id)

    # get a  monster to buff
    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    expect { gameboards(:gameboardFourPlayers).interceptcard.add_card_with_ingamedeck_id(ingamedeck_card.id) }.to change { gameboards(:gameboardFourPlayers).monster_atk }
  end
end
