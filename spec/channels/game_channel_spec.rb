# frozen_string_literal: true

# https://www.rubydoc.info/gems/action-cable-testing/0.3.0/RSpec/Rails/Matchers
# https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/setting-constraints/matching-arguments

require 'rails_helper'

RSpec.describe GameChannel, type: :channel do
  fixtures :users, :players, :gameboards, :centercards

  before do
    # initialize connection with identifiers
    users(:usernorbert).player = players(:playernorbert)
    stub_connection current_user: users(:usernorbert)
    # srand sets the seed for the rnd generator of rails => rails returns the same value if srand is sets
    srand(1)
  end

  it 'successfully subscribe to channel when player and gameboard was already created previously' do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("game:#{users(:usernorbert).player.gameboard.to_gid_param}")
    expect(users(:usernorbert).player.gameboard).to be_truthy
  end

  it 'test if flee broadcasts to all players' do
    subscribe

    expect do
      perform('flee', {})
    end
      .to have_broadcasted_to("game:#{users(:usernorbert).player.gameboard.to_gid_param}")
      .with(
        type: 'FLEE', params: { flee: true, value: 6 }
      ).exactly(:once)
      .and have_broadcasted_to("game:#{users(:usernorbert).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'GAME_LOG')
      ).exactly(:once)
      .and have_broadcasted_to("game:#{users(:usernorbert).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)
    # type: 'GAME_LOG', params: { log: {date: @time_now, message: "Nice! #{connection.current_user.name} rolled 6, #{connection.current_user.name} managed to escape :)"} }
  end
end
