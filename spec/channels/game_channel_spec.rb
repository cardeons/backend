# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameChannel, type: :channel do
  fixtures :users, :players, :gameboards, :centercards

  before do
    # initialize connection with identifiers
    users(:usernorbert).player = players(:playernorbert)
    stub_connection current_user: users(:usernorbert)
  end

  it 'successfully subscribe to channel when player and gameboard was already created previously' do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("game:#{users(:usernorbert).player.gameboard.to_gid_param}")
    expect(users(:usernorbert).player.gameboard).to be_truthy
  end
end
