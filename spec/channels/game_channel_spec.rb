# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameChannel, type: :channel do
  fixtures :users, :players, :gameboards

  before do
    # initialize connection with identifiers
    users(:usernorbert).player=players(:playernorbert)
    stub_connection current_user: users(:usernorbert)
  end

  it 'subscribe to channel' do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("game:#{users(:usernorbert).player.gameboard.to_gid_param}")
    expect(player(:one).player).to exist
  end
end
