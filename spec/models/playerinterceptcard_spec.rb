# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Playerinterceptcard, type: :model do
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

    expect(gameboards(:gameboardFourPlayers).playerinterceptcard.ingamedecks.find_by('id=?', ingamedeck_card.id)).to be_falsy

    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    gameboards(:gameboardFourPlayers).playerinterceptcard.add_card_with_ingamedeck_id(ingamedeck_card.id)

    expect(player.handcard.ingamedecks.find_by('id=?', ingamedeck_card.id)).to be_falsy
    expect(gameboards(:gameboardFourPlayers).playerinterceptcard.ingamedecks.find_by('id=?', ingamedeck_card.id)).to be_truthy
  end

  it 'playerinterceptcard should increase player dmg' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    player = gameboards(:gameboardFourPlayers).players.first
    player.handcard.ingamedecks.create(card: cards(:buffcard), gameboard: gameboards(:gameboardFourPlayers))
    # player should now have a buffcard
    ingamedeck_card = player.handcard.ingamedecks.find_by!('card_id=?', cards(:buffcard).id)

    # get a  monster to buff
    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    old_atk = gameboards(:gameboardFourPlayers).player_atk

    buff_atk = cards(:buffcard).atk_points

    # checks if player atk got increased
    expect { gameboards(:gameboardFourPlayers).playerinterceptcard.add_card_with_ingamedeck_id(ingamedeck_card.id) }.to(change do
                                                                                                                          gameboards(:gameboardFourPlayers).player_atk
                                                                                                                        end.from(old_atk).to(old_atk + buff_atk))
  end
end
