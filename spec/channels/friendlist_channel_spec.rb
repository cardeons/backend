# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlistChannel, type: :channel do
  fixtures :users, :players, :gameboards, :centercards, :cards, :graveyards

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
        hash_including(type: 'FRIEND_LOG', params: { message: "🤝 You sent a friendrequest to #{users(:usernorbert).name}" })
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
        hash_including(type: 'FRIEND_LOG', params: { message: "🤝 You sent a friendrequest to #{users(:usernorbert).name}" })
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
        hash_including(type: 'FRIEND_LOG', params: { message: "✅ You accepted a friendrequest from #{users(:one).name}" })
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
        hash_including(type: 'FRIEND_LOG', params: { message: "🤝 You sent a friendrequest to #{users(:usernorbert).name}" })
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
        hash_including(type: 'FRIEND_LOG', params: { message: "❌ You declined a friendrequest from #{users(:one).name}" })
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
        hash_including(type: 'FRIEND_LOG', params: { message: "🤝 You sent a friendrequest to #{users(:usernorbert).name}" })
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
        hash_including(type: 'FRIEND_LOG', params: { message: "❌ You declined a friendrequest from #{users(:one).name}" })
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
        hash_including(type: 'FRIEND_LOG', params: { message: "🤝 You sent a friendrequest to #{users(:usernorbert).name}" })
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
end
