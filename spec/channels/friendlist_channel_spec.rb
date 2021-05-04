# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlistChannel, type: :channel do
  fixtures :users

  before do
    # initialize connection with identifiers
    stub_connection current_user: users(:usernorbert)
  end

  it 'test if current user is online after subscribe & offline after unsubscribe' do
    stub_connection current_user: users(:one)
    subscribe
    expect(connection.current_user.status).to eq 'online'
    unsubscribe
    expect(connection.current_user.status).to eq 'offline'
  end

  it 'test if friendrequest is broadcastet' do
    stub_connection current_user: users(:one)
    subscribe

    expect do
      perform('send_friend_request', {
                friend: users(:usernorbert).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_LOG', params: { message: "You sent a friendrequest to #{users(:usernorbert).name}" })
      ).exactly(:once)

    unsubscribe

    stub_connection current_user: users(:usernorbert)
    expect do
      subscribe
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_REQUEST', params: { inquirer: users(:one).id, inquirer_name: users(:one).name })
      ).exactly(:once)
  end

  it 'test if friendrequest is accepted' do
    stub_connection current_user: users(:one)
    subscribe

    expect do
      perform('send_friend_request', {
                friend: users(:usernorbert).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_LOG', params: { message: "You sent a friendrequest to #{users(:usernorbert).name}" })
      ).exactly(:once)

    unsubscribe

    stub_connection current_user: users(:usernorbert)
    subscribe

    expect do
      perform('accept_friend_request', {
                inquirer: users(:one).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_LOG', params: { message: "You accepted a friendrequest from #{users(:one).name}" })
      ).exactly(:once)

    expect(users(:usernorbert).friends.count).to eq 1
    expect(users(:usernorbert).friendships.first.pending).to be_falsy
  end

  it 'test if friendrequest is declined' do
    stub_connection current_user: users(:one)
    subscribe

    expect do
      perform('send_friend_request', {
                friend: users(:usernorbert).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_LOG', params: { message: "You sent a friendrequest to #{users(:usernorbert).name}" })
      ).exactly(:once)

    unsubscribe

    stub_connection current_user: users(:usernorbert)
    subscribe

    expect do
      perform('decline_friend_request', {
                inquirer: users(:one).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_LOG', params: { message: "You declined a friendrequest from #{users(:one).name}" })
      ).exactly(:once)

    expect(users(:usernorbert).friends.count).to eq 0
  end

  it 'test if friendrequest is declined fails with wrong id' do
    stub_connection current_user: users(:one)
    subscribe

    expect do
      perform('send_friend_request', {
                friend: users(:usernorbert).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_LOG', params: { message: "You sent a friendrequest to #{users(:usernorbert).name}" })
      ).exactly(:once)

    unsubscribe

    stub_connection current_user: users(:usernorbert)
    subscribe

    expect do
      perform('decline_friend_request', {
                inquirer: users(:two).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_LOG', params: { message: "You declined a friendrequest from #{users(:one).name}" })
      ).exactly(0)
  end

  it 'test if friends get broadcastet on subscribe' do
    Friendship.create(user: users(:usernorbert), friend: users(:two), inquirer: users(:usernorbert), pending: false)
    Friendship.create(user: users(:usernorbert), friend: users(:one), inquirer: users(:usernorbert), pending: false)

    stub_connection current_user: users(:usernorbert)
    expect do
      subscribe
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIENDLIST')
      ).exactly(:once)
  end

  it 'test if friendrequest is broadcasted to the right user' do
    stub_connection current_user: users(:one)
    subscribe

    expect do
      perform('send_friend_request', {
                friend: users(:usernorbert).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_LOG', params: { message: "You sent a friendrequest to #{users(:usernorbert).name}" })
      ).exactly(:once)

    unsubscribe

    expect do
      subscribe
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_REQUEST', params: { inquirer: users(:one).id, inquirer_name: users(:one).name })
      ).exactly(0)

    unsubscribe

    stub_connection current_user: users(:usernorbert)
    expect do
      subscribe
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'FRIEND_REQUEST', params: { inquirer: users(:one).id, inquirer_name: users(:one).name })
      ).exactly(:once)
  end

  it 'test if user to lobby after successfull invitation' do
    stub_connection current_user: users(:one)
    subscribe

    perform('initiate_lobby')
    perform('lobby_invite', {
              friend: users(:usernorbert).id
            })

    unsubscribe

    stub_connection current_user: users(:usernorbert)
    subscribe

    perform('accept_lobby_invite', {
              inquirer: users(:one).id
            })

    expect(users(:usernorbert).reload.lobby).to eq users(:one).lobby

    expect(users(:one).lobby.users.count).to eq 2
  end

  it 'test if broadcast if lobby is full' do
    stub_connection current_user: users(:one)
    subscribe

    perform('initiate_lobby')

    unsubscribe
    stub_connection current_user: users(:usernorbert)
    subscribe

    expect do
      perform('accept_lobby_invite', {
                inquirer: users(:one).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'LOBBY_ERROR', params: { message: 'Lobby is full...' })
      ).exactly(0)

    unsubscribe
    stub_connection current_user: users(:two)
    subscribe

    expect do
      perform('accept_lobby_invite', {
                inquirer: users(:one).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'LOBBY_ERROR', params: { message: 'Lobby is full...' })
      ).exactly(0)

    unsubscribe
    stub_connection current_user: users(:three)
    subscribe

    expect do
      perform('accept_lobby_invite', {
                inquirer: users(:one).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'LOBBY_ERROR', params: { message: 'Lobby is full...' })
      ).exactly(0)

    unsubscribe
    stub_connection current_user: users(:four)
    subscribe

    expect do
      perform('accept_lobby_invite', {
                inquirer: users(:one).id
              })
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'LOBBY_ERROR', params: { message: 'Lobby is full...' })
      ).exactly(:once)

    expect(users(:one).lobby.users.count).to eq 4
  end

  it 'test startqueue with single player' do
    stub_connection current_user: users(:one)
    subscribe

    perform('initiate_lobby')
    expect do
      perform('start_lobby_queue')
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'SUBSCRIBE_LOBBY')
      ).exactly(:once)

    expect(users(:one).reload.player).to be_truthy
  end

  it 'test startqueue with 3 player' do
    stub_connection current_user: users(:one)
    subscribe

    perform('initiate_lobby')

    unsubscribe
    stub_connection current_user: users(:two)
    subscribe

    perform('accept_lobby_invite', {
              inquirer: users(:one).id
            })

    unsubscribe
    stub_connection current_user: users(:three)
    subscribe

    perform('accept_lobby_invite', {
              inquirer: users(:one).id
            })

    expect do
      perform('start_lobby_queue')
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'SUBSCRIBE_LOBBY')
      ).exactly(:once)

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
    subscribe

    perform('initiate_lobby')

    unsubscribe
    stub_connection current_user: users(:two)
    subscribe

    perform('accept_lobby_invite', {
              inquirer: users(:one).id
            })

    unsubscribe
    stub_connection current_user: users(:three)
    subscribe

    perform('accept_lobby_invite', {
              inquirer: users(:one).id
            })

    expect do
      perform('start_lobby_queue')
    end.to have_broadcasted_to(FriendlistChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'SUBSCRIBE_LOBBY')
      ).exactly(:once)

    expect(users(:one).player.gameboard).to_not eq gameboard
    expect(users(:one).player.gameboard).to be_truthy
  end
end
