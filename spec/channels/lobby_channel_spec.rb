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

  it 'successfully subscribes and creates a player for the user' do
    subscribe
    expect(users(:one).player).to be_truthy
  end

  
  it 'successfully creates all decks for the user' do
    subscribe
    users(:one).player.inventory.ingamedecks.cards
    expect(users(:one).player.inventory.ingamedecks.cards.count).to be_truthy
  end

  it 'test database contains three users' do
    expect(User.all.count).to eq(3)
  end
end
