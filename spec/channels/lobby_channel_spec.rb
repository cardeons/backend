# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LobbyChannel, type: :channel do
  fixtures :users, :cards

  LOBBY = 'lobby'

  before do
    # initialize connection with identifiers
    gameboard = Gameboard.create(current_state: LOBBY)
    Player.create!(name: users(:one).name, gameboard_id: gameboard.id, user: users(:one))
    Player.create!(name: users(:two).name, gameboard_id: gameboard.id, user: users(:two))
    Player.create!(name: users(:three).name, gameboard_id: gameboard.id, user: users(:three))
    Player.create!(name: users(:four).name, gameboard_id: gameboard.id, user: users(:four))

    stub_connection current_user: users(:one)
  end

  after(:each) do
    ENV['DEV_TOOL_ENABLED'] = nil
  end

  # it 'user does not already have a player before the game' do
  #   expect(users(:one).player).to be_nil
  # end

  it 'successfully subscribes' do
    subscribe
    expect(subscription).to be_confirmed
  end

  it 'user streams from lobby_channel' do
    subscribe
    # uses global id of model
    expect(subscription).to have_stream_from("lobby:#{users(:one).player.gameboard.to_gid_param}")
  end

  it 'successfully subscribes and creates a player for the user' do
    subscribe
    expect(users(:one).player).to be_truthy
  end

  it 'successfully creates handcard deck for the user' do
    subscribe
    expect(User.find(users(:one).id).player.handcard).to be_truthy
  end

  it 'successfully assigns player to a gameboard' do
    subscribe
    expect(User.find(users(:one).id).player.gameboard).to be_truthy
  end

  it 'successfully creates inventory for player' do
    subscribe
    expect(User.find(users(:one).id).player.inventory).to be_truthy
  end

  it 'successfully creates handcards for player' do
    subscribe
    expect(User.find(users(:one).id).player.handcard.cards.count).to be_truthy
  end

  it 'creates monsterdeck for players' do
    subscribe
    expect(User.find(users(:one).id).player.monsterone).to be_truthy
    expect(User.find(users(:one).id).player.monstertwo).to be_truthy
    expect(User.find(users(:one).id).player.monsterthree).to be_truthy
  end

  it 'adds monsters to handcards if player brought some' do
    subscribe monsterone: 1, monstertwo: 2, monsterthree: 3
    expect(User.find(users(:one).id).player.handcard.cards.find(1)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(2)).to be_truthy
    expect(User.find(users(:one).id).player.handcard.cards.find(3)).to be_truthy
  end

  it 'gameboard got initalized ' do
    stub_connection current_user: users(:one)
    subscribe
    stub_connection current_user: users(:two)
    subscribe
    stub_connection current_user: users(:three)
    subscribe
    stub_connection current_user: users(:four)
    subscribe

    expect(User.find(users(:one).id).player.gameboard.centercard).to be_truthy
    expect(User.find(users(:one).id).player.gameboard.graveyard).to be_truthy
    expect(User.find(users(:one).id).player.gameboard.ingamedeck).to be_truthy
  end

  it 'players draw 5 cards ' do
    stub_connection current_user: users(:one)
    subscribe
    stub_connection current_user: users(:two)
    subscribe
    stub_connection current_user: users(:three)
    subscribe
    stub_connection current_user: users(:four)
    subscribe
    expect(User.find(users(:one).id).player.handcard.cards.count).to eql(5)
    expect(User.find(users(:two).id).player.handcard.cards.count).to eql(5)
    expect(User.find(users(:three).id).player.handcard.cards.count).to eql(5)
    expect(User.find(users(:four).id).player.handcard.cards.count).to eql(5)
  end

  it '4 players get assigned to the game' do
    stub_connection current_user: users(:one)
    subscribe
    stub_connection current_user: users(:two)
    subscribe
    stub_connection current_user: users(:three)
    subscribe
    stub_connection current_user: users(:four)
    subscribe
    expect(User.find(users(:one).id).player.gameboard.players.count).to eql(4)
  end

  it 'should delete old player from old gameboard if user joins again' do
    stub_connection current_user: users(:one)
    subscribe
    expect(Player.where('user_id=?', users(:one).id).count).to eql(1)
    stub_connection current_user: users(:one)
    subscribe
    expect(Player.where('user_id=?', users(:one).id).count).to eql(1)
  end

  it 'create new test game accepts params for how many players to add to game' do
    users(:two).player.destroy!
    users(:three).player.destroy!
    users(:four).player.destroy!
    stub_connection current_user: users(:one)
    ENV['DEV_TOOL_ENABLED'] = 'enabled'
    subscribe(testplayers: 2)

    expect(users(:one).player.gameboard.players.size).to eql(3)
  end

  it 'if no testplayers are sent 1 player should be in lobby' do
    users(:two).player.destroy!
    users(:three).player.destroy!
    users(:four).player.destroy!
    stub_connection current_user: users(:one)
    subscribe

    expect(users(:one).player.gameboard.players.size).to eql(1)
  end

  it 'if testplayer count is higher than 3 use 3 for a full game' do
    users(:two).player.destroy!
    users(:three).player.destroy!
    users(:four).player.destroy!
    stub_connection current_user: users(:one)
    ENV['DEV_TOOL_ENABLED'] = 'enabled'
    subscribe(testplayers: 4)

    expect(users(:one).player.gameboard.players.size).to eql(4)
  end

  it 'player is kicked from game if he unsubscribes in lobby' do
    # user has no player
    users(:four).player.destroy!
    stub_connection current_user: users(:one)
    subscribe

    expect(users(:one).player).to be_truthy
    unsubscribe
    users(:one).reload
    expect(users(:one).player).to be_falsy
  end
end
