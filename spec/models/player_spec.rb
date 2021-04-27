# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Player, type: :model do
  fixtures :users, :players, :gameboards

  it 'init_player should creat all cardtables ' do
    expect(players(:singleplayer).handcard).to be_falsy
    expect(players(:singleplayer).playercurse).to be_falsy
    expect(players(:singleplayer).monsterone).to be_falsy
    expect(players(:singleplayer).monstertwo).to be_falsy
    expect(players(:singleplayer).monsterthree).to be_falsy
    expect(players(:singleplayer).inventory).to be_falsy
    players(:singleplayer).init_player
    expect(players(:singleplayer).handcard).to be_truthy
    expect(players(:singleplayer).playercurse).to be_truthy
    expect(players(:singleplayer).monsterone).to be_truthy
    expect(players(:singleplayer).monstertwo).to be_truthy
    expect(players(:singleplayer).monsterthree).to be_truthy
    expect(players(:singleplayer).inventory).to be_truthy
  end

  it 'render player should return object ' do
    players(:singleplayer).init_player

    player = players(:singleplayer)

    expected_return = {
      name: player.name,
      player_id: player.id,
      inventory: Gameboard.render_cards_array(player.inventory.ingamedecks),
      level: player.level,
      attack: player.attack,
      handcard: player.handcard.cards.count,
      intercept: false,
      monsters: [],
      playercurse: Gameboard.render_cards_array(player.playercurse.ingamedecks),
      user_id: player.user.id
    }

    expect(players(:singleplayer).render_player).to eql(expected_return)
  end
end
