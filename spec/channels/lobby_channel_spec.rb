# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LobbyChannel, type: :channel do
  fixtures :users

  before do
    # initialize connection with identifiers
    stub_connection current_user: users(:one)
  end

  it 'user does not already have a player before the game' do
    expect(users(:one).player).to be_nil
  end

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
end
