# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LobbyChannel, type: :channel do
  fixtures :users, :cards

  LOBBY = 'lobby'

  before do
    # initialize connection with identifiers
    # gameboard = Gameboard.create(current_state: LOBBY)
    # Player.create!(name: users(:one).name, gameboard_id: gameboard.id, user: users(:one))
    # Player.create!(name: users(:two).name, gameboard_id: gameboard.id, user: users(:two))
    # Player.create!(name: users(:three).name, gameboard_id: gameboard.id, user: users(:three))
    # Player.create!(name: users(:four).name, gameboard_id: gameboard.id, user: users(:four))

    stub_connection current_user: users(:one)
  end

  after(:each) do
    ENV['DEV_TOOL_ENABLED'] = nil
  end

  it 'user does not already have a player before the game' do
    expect(users(:one).player).to be_nil
  end

  it 'successfully subscribes' do
    subscribe initiate: true
    expect(subscription).to be_confirmed
  end

  it 'user streams from lobby_channel' do
    stub_connection current_user: users(:one)
    subscribe initiate: true
    perform('start_lobby_queue')
    expect(subscription).to have_stream_from("lobby:#{users(:one).lobby.to_gid_param}")
    # uses global id of model
    # expect(subscription).to have_stream_from("lobby:#{users(:one).lobby.to_gid_param}")
  end

  it 'successfully subscribes and creates a player for the user' do
    subscribe initiate: true
    perform('start_lobby_queue')
    expect(users(:one).player).to be_truthy
  end

  it 'successfully creates handcard deck for the user' do
    subscribe initiate: true
    perform('start_lobby_queue')
    expect(User.find(users(:one).id).player.handcard).to be_truthy
  end

  it 'successfully assigns player to a gameboard' do
    subscribe initiate: true
    perform('start_lobby_queue')
    expect(User.find(users(:one).id).player.gameboard).to be_truthy
  end

  it 'successfully creates inventory for player' do
    subscribe initiate: true
    perform('start_lobby_queue')
    expect(User.find(users(:one).id).player.inventory).to be_truthy
  end

  it 'successfully creates handcards for player' do
    subscribe initiate: true
    perform('start_lobby_queue')
    expect(User.find(users(:one).id).player.handcard.cards.count).to be_truthy
  end

  it 'creates monsterdeck for players' do
    subscribe initiate: true
    perform('start_lobby_queue')
    expect(User.find(users(:one).id).player.monsterone).to be_truthy
    expect(User.find(users(:one).id).player.monstertwo).to be_truthy
    expect(User.find(users(:one).id).player.monsterthree).to be_truthy
  end

  it 'adds monsters to handcards if player brought some' do
    subscribe initiate: true
    perform('add_monster', {
              monster_id: 1
            })
    perform('add_monster', {
              monster_id: 2
            })
    perform('add_monster', {
              monster_id: 3
            })
    perform('start_lobby_queue')

    expect(User.find(users(:one).id).player.handcard.cards.find(1)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(2)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(3)).to be_truthy
  end

  it 'adds monsters to handcards if multiple players brought some' do
    subscribe initiate: true
    perform('add_monster', {
              monster_id: 1
            })
    perform('add_monster', {
              monster_id: 2
            })
    perform('add_monster', {
              monster_id: 3
            })
    stub_connection current_user: users(:two)
    subscribe lobby_id: users(:one).lobby.id
    perform('add_monster', {
              monster_id: 2
            })
    perform('start_lobby_queue')

    expect(User.find(users(:one).id).player.handcard.cards.find(1)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(2)).to be_truthy
    expect(User.find(users(:two).id).player.handcard.cards.find(2)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(3)).to be_truthy
  end

  it 'removes monsters from handcards if players deletes some' do
    subscribe initiate: true
    perform('add_monster', {
              monster_id: 1
            })
    perform('add_monster', {
              monster_id: 2
            })
    perform('add_monster', {
              monster_id: 3
            })
    perform('remove_monster', {
              monster_id: 3
            })

    perform('start_lobby_queue')

    expect(User.find(users(:one).id).player.handcard.cards.find(1)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(2)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.count).to eq 2
  end

  it 'removes monsters from handcards if players deletes some' do
    subscribe initiate: true
    perform('add_monster', {
              monster_id: 1
            })
    perform('add_monster', {
              monster_id: 2
            })
    perform('add_monster', {
              monster_id: 3
            })
    perform('remove_monster', {
              monster_id: 2
            })

    perform('start_lobby_queue')

    expect(User.find(users(:one).id).player.handcard.cards.find(1)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(3)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.count).to eq 2
  end

  it 'gameboard got initalized player does not have cards from unsubscribe' do
    stub_connection current_user: users(:one)
    subscribe initiate: true
    perform('add_monster', {
              monster_id: 1
            })
    perform('add_monster', {
              monster_id: 2
            })
    perform('add_monster', {
              monster_id: 3
            })
    stub_connection current_user: users(:two)
    expect do
      subscribe lobby_id: users(:one).lobby.id
    end
      .to have_broadcasted_to("lobby:#{users(:one).lobby.to_gid_param}")
      .with(
        hash_including(type: 'LOBBY_UPDATE')
      ).exactly(:once)
    perform('add_monster', {
              monster_id: 4
            })
    perform('add_monster', {
              monster_id: 5
            })
    unsubscribe
    subscribe lobby_id: users(:one).lobby.id
    stub_connection current_user: users(:three)
    subscribe lobby_id: users(:one).lobby.id
    perform('add_monster', {
              monster_id: 1
            })
    stub_connection current_user: users(:four)
    subscribe lobby_id: users(:one).lobby.id
    perform('start_lobby_queue')

    expect(User.find(users(:one).id).player.handcard.cards.find(1)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(2)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(3)).to be_truthy

    expect(User.find(users(:two).id).player.handcard.cards.find_by(id: 4)).to be_falsy
    expect(User.find(users(:two).id).player.handcard.cards.find_by(id: 5)).to be_falsy

    expect(User.find(users(:three).id).player.handcard.cards.find(1)).to be_truthy

    expect(User.find(users(:one).id).player.handcard.cards.count).to eq 5
    expect(User.find(users(:two).id).player.handcard.cards.count).to eq 5
    expect(User.find(users(:three).id).player.handcard.cards.count).to eq 5
    expect(User.find(users(:four).id).player.handcard.cards.count).to eq 5
  end

  it 'gameboard got initalized every player has 5 cards even if he brought cards' do
    stub_connection current_user: users(:one)
    subscribe initiate: true
    perform('add_monster', {
              monster_id: 1
            })
    perform('add_monster', {
              monster_id: 2
            })
    perform('add_monster', {
              monster_id: 3
            })
    stub_connection current_user: users(:two)
    expect do
      subscribe lobby_id: users(:one).lobby.id
    end
      .to have_broadcasted_to("lobby:#{users(:one).lobby.to_gid_param}")
      .with(
        hash_including(type: 'LOBBY_UPDATE')
      ).exactly(:once)
    perform('add_monster', {
              monster_id: 4
            })
    perform('add_monster', {
              monster_id: 5
            })
    stub_connection current_user: users(:three)
    subscribe lobby_id: users(:one).lobby.id
    perform('add_monster', {
              monster_id: 1
            })
    stub_connection current_user: users(:four)
    subscribe lobby_id: users(:one).lobby.id
    perform('start_lobby_queue')

    expect(User.find(users(:one).id).player.handcard.cards.find(1)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(2)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(3)).to be_truthy

    expect(User.find(users(:two).id).player.handcard.cards.find(4)).to be_truthy
    expect(User.find(users(:two).id).player.handcard.cards.find(5)).to be_truthy

    expect(User.find(users(:three).id).player.handcard.cards.find(1)).to be_truthy

    expect(User.find(users(:one).id).player.handcard.cards.count).to eq 5
    expect(User.find(users(:two).id).player.handcard.cards.count).to eq 5
    expect(User.find(users(:three).id).player.handcard.cards.count).to eq 5
    expect(User.find(users(:four).id).player.handcard.cards.count).to eq 5
  end

  it 'gameboard got initalized ' do
    stub_connection current_user: users(:one)
    subscribe initiate: true
    stub_connection current_user: users(:two)
    subscribe lobby_id: users(:one).lobby.id
    stub_connection current_user: users(:three)
    subscribe lobby_id: users(:one).lobby.id
    stub_connection current_user: users(:four)
    subscribe lobby_id: users(:one).lobby.id
    perform('start_lobby_queue')

    expect(User.find(users(:one).id).player.gameboard.centercard).to be_truthy
    expect(User.find(users(:one).id).player.gameboard.graveyard).to be_truthy
    expect(User.find(users(:one).id).player.gameboard.ingamedeck).to be_truthy
  end

  it 'players draw 5 cards ' do
    stub_connection current_user: users(:one)
    subscribe initiate: true
    stub_connection current_user: users(:two)
    subscribe lobby_id: users(:one).lobby.id
    stub_connection current_user: users(:three)
    subscribe lobby_id: users(:one).lobby.id
    stub_connection current_user: users(:four)
    subscribe lobby_id: users(:one).lobby.id
    perform('start_lobby_queue')

    expect(User.find(users(:one).id).player.handcard.cards.count).to eql(5)
    expect(User.find(users(:two).id).player.handcard.cards.count).to eql(5)
    expect(User.find(users(:three).id).player.handcard.cards.count).to eql(5)
    expect(User.find(users(:four).id).player.handcard.cards.count).to eql(5)
  end

  it '4 players get assigned to the game' do
    stub_connection current_user: users(:one)
    subscribe initiate: true

    lobby_id = users(:one).lobby.id

    stub_connection current_user: users(:two)
    subscribe lobby_id: users(:one).lobby.id
    stub_connection current_user: users(:three)
    subscribe lobby_id: users(:one).lobby.id
    stub_connection current_user: users(:four)
    subscribe lobby_id: users(:one).lobby.id
    perform('start_lobby_queue')

    expect(User.find(users(:one).id).player.gameboard.players.count).to eql(4)
    expect(Lobby.find_by(id: lobby_id)).to be_falsy
  end

  it 'should delete old player from old gameboard if user joins again' do
    stub_connection current_user: users(:one)
    subscribe initiate: true
    perform('start_lobby_queue')
    expect(Player.where('user_id=?', users(:one).id).count).to eql(1)
    unsubscribe
    stub_connection current_user: users(:one)
    subscribe initiate: true
    perform('start_lobby_queue')
    expect(Player.where('user_id=?', users(:one).id).count).to eql(1)
  end

  it 'create new test game accepts params for how many players to add to game' do
    stub_connection current_user: users(:one)
    ENV['DEV_TOOL_ENABLED'] = 'enabled'
    subscribe initiate: true
    perform('start_lobby_queue', {
              testplayers: 2
            })

    expect(users(:one).player.gameboard.players.size).to eql(3)
  end

  it 'if no testplayers are sent 1 player should be in lobby' do
    stub_connection current_user: users(:one)
    subscribe initiate: true
    perform('start_lobby_queue')

    expect(users(:one).player.gameboard.players.size).to eql(1)
  end

  it 'if testplayer count is higher than 3 use 3 for a full game' do
    stub_connection current_user: users(:one)
    ENV['DEV_TOOL_ENABLED'] = 'enabled'
    subscribe initiate: true
    perform('start_lobby_queue', {
              testplayers: 4
            })

    expect(users(:one).player.gameboard.players.size).to eql(4)
  end

  it 'player is kicked from game if he unsubscribes in lobby' do
    # user has no player
    stub_connection current_user: users(:one)
    subscribe initiate: true
    perform('start_lobby_queue')

    expect(users(:one).player).to be_truthy
    unsubscribe
    users(:one).reload
    expect(users(:one).player).to be_falsy
  end

  it 'test if user to lobby after successfull invitation' do
    stub_connection current_user: users(:one)
    subscribe initiate: true

    perform('lobby_invite', {
              friend: users(:usernorbert).id
            })

    # unsubscribe

    stub_connection current_user: users(:usernorbert)
    subscribe lobby_id: users(:one).lobby.id

    expect(users(:usernorbert).reload.lobby).to eq users(:one).lobby

    expect(users(:one).reload.lobby.reload.users.count).to eq 2
  end

  it 'test if only 4 players in lobby' do
    stub_connection current_user: users(:one)
    subscribe initiate: true

    stub_connection current_user: users(:usernorbert)
    subscribe initiate: false, lobby_id: users(:one).lobby.id

    stub_connection current_user: users(:two)
    subscribe lobby_id: users(:one).lobby.id

    stub_connection current_user: users(:three)
    subscribe lobby_id: users(:one).lobby.id

    stub_connection current_user: users(:four)
    subscribe lobby_id: users(:one).lobby.id

    expect(users(:one).lobby.users.count).to eq 4
  end

  it 'test startqueue with single player' do
    stub_connection current_user: users(:one)
    subscribe initiate: true

    perform('start_lobby_queue')

    expect(users(:one).reload.player).to be_truthy
  end

  it 'test startqueue with 3 player' do
    stub_connection current_user: users(:one)
    subscribe initiate: true

    stub_connection current_user: users(:two)
    subscribe lobby_id: users(:one).lobby.id

    stub_connection current_user: users(:three)
    subscribe lobby_id: users(:one).lobby.id

    perform('start_lobby_queue')

    expect(users(:one).reload.player).to be_truthy
    expect(users(:two).reload.player).to be_truthy
    expect(users(:three).reload.player).to be_truthy
  end

  it 'test startqueue gets new gameboard if existing has no space for all players from lobby' do
    gameboard = Gameboard.create!
    gameboard.lobby!
    Player.create!(name: users(:four).name, gameboard_id: gameboard.id, user: users(:four))
    Player.create!(name: users(:five).name, gameboard_id: gameboard.id, user: users(:five))
    Player.create!(name: users(:six).name, gameboard_id: gameboard.id, user: users(:six))

    stub_connection current_user: users(:one)
    subscribe initiate: true

    stub_connection current_user: users(:two)
    subscribe lobby_id: users(:one).lobby.id

    stub_connection current_user: users(:three)
    subscribe lobby_id: users(:one).lobby.id

    perform('start_lobby_queue')

    expect(users(:one).player.gameboard).to_not eq gameboard
    expect(users(:one).player.gameboard).to be_truthy
  end

  it 'test if user gets kicked if unsubscribe and rejoins on subscribe' do
    stub_connection current_user: users(:one)
    subscribe initiate: true

    stub_connection current_user: users(:two)
    subscribe lobby_id: users(:one).lobby.id

    stub_connection current_user: users(:three)
    subscribe lobby_id: users(:one).lobby.id
    unsubscribe

    expect(users(:one).lobby.users.count).to eq 2

    subscribe lobby_id: users(:one).lobby.id

    expect(users(:one).lobby.users.count).to eq 3
  end

  it 'test if user gets kicked if unsubscribe and rejoins on subscribe' do
    stub_connection current_user: users(:one)
    subscribe initiate: true

    stub_connection current_user: users(:two)
    subscribe lobby_id: users(:one).lobby.id

    stub_connection current_user: users(:three)
    subscribe lobby_id: users(:one).lobby.id
    unsubscribe

    expect(users(:one).lobby.users.count).to eq 2

    subscribe lobby_id: users(:one).lobby.id

    expect(users(:one).lobby.users.count).to eq 3
  end

  it 'test if lobby gets destroyed after last one leaves' do
    stub_connection current_user: users(:one)
    subscribe initiate: true

    lobby_id = users(:one).lobby.id
    unsubscribe
    expect(Lobby.find_by(id: lobby_id)).to be_falsy
  end

  it 'test if lobby gets destroyed after last one leaves' do
    stub_connection current_user: users(:one)
    subscribe initiate: true

    lobby_id = users(:one).lobby.id
    unsubscribe
    expect(Lobby.find_by(id: lobby_id)).to be_falsy
  end

  it 'test if lobby does not get destroyed after intiating one leaves' do
    stub_connection current_user: users(:one)
    subscribe initiate: true
    lobby_id = users(:one).lobby.id
    stub_connection current_user: users(:two)
    subscribe lobby_id: lobby_id
    stub_connection current_user: users(:one)
    subscribe initiate: true
    unsubscribe

    expect(Lobby.find_by(id: lobby_id)).to be_truthy
  end
end
