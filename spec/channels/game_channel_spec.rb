# frozen_string_literal: true

# https://www.rubydoc.info/gems/action-cable-testing/0.3.0/RSpec/Rails/Matchers
# https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/setting-constraints/matching-arguments

require 'rails_helper'

RSpec.describe GameChannel, type: :channel do
  fixtures :users, :players, :gameboards, :centercards, :cards, :graveyards

  before do
    # initialize connection with identifiers
    users(:usernorbert).player = players(:singleplayer)
    users(:usernorbert).player.init_player
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
    connection.current_user.player.gameboard.update(current_player: players(:singleplayer).id)

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

  it 'test if intercept broadcasts to all players' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first

    player = users(:one).player

    stub_connection current_user: users(:one)

    expect do
      subscribe
    end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

    # give player a buffcard
    player.handcard.ingamedecks.create(card: cards(:buffcard), gameboard: gameboards(:gameboardFourPlayers))

    expect do
      perform('intercept', {
                unique_card_id: player.handcard.ingamedecks.find_by('card_id=?', cards(:buffcard).id),
                to: 'center_card'
              })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'HANDCARD_UPDATE')
      ).exactly(:once)
      .and have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

      expect(player.gameboard.current_state).to eql('intercept_phase')

  end

  it 'test if intercept broadcasts to all players when buffing player' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first

    player = users(:one).player

    stub_connection current_user: users(:one)

    expect do
      subscribe
    end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

    # give player a buffcard
    player.handcard.ingamedecks.create(card: cards(:buffcard), gameboard: gameboards(:gameboardFourPlayers))

    expect do
      perform('intercept', {
                unique_card_id: player.handcard.ingamedecks.find_by('card_id=?', cards(:buffcard).id),
                to: 'current_player'
              })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'HANDCARD_UPDATE')
      ).exactly(:once)
      .and have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)
  end

  it 'test if player gets error when using a wrong ingame_deck_id or wrong card type' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first

    stub_connection current_user: users(:one)
    subscribe

    expect do
      perform('intercept', {
                unique_card_id: 3,
                to: 'center_card'
              })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'ERROR')
      ).exactly(:once)
      .and have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        # there should be no broadcast since this action was invalid
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(0).times

    # give user a wrong card for intercepts
    player = users(:one).player

    player.handcard.ingamedecks.create(card: cards(:itemcard), gameboard: gameboards(:gameboardFourPlayers))

    expect do
      perform('intercept', {
                unique_card_id: 3,
                to: 'center_card'
              })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'ERROR')
      ).exactly(:once)
      .and have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        # there should be no broadcast since this action was invalid
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(0).times
  end

  it 'test if no_intercept sends board update when all players have decided not to intercept' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    users(:userOne).player = gameboards(:gameboardFourPlayers).players.first

    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    stub_connection current_user: users(:userTwo)
    subscribe


    # player 2 doesn't want to intercept
      perform('no_intercept', {
                player_id: connection.current_user.player.id
              })

      expect(connection.current_user.player.intercept).to be_falsy   

    stub_connection current_user: users(:userThree)
    subscribe

    # player 3 doesn't want to intercept
    perform('no_intercept', {
        player_id: connection.current_user.player.id
      })

    expect(connection.current_user.player.intercept).to be_falsy   

    stub_connection current_user: users(:userFour)
    subscribe

    # player 4 doesn't want to intercept
      expect do
        perform('no_intercept', {
        player_id: connection.current_user.player.id
      })
      end.to have_broadcasted_to("game:#{users(:userFour).player.gameboard.to_gid_param}")
      .with(
        # should now send broadcast because all 3 players do not want to intercept
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(1).times

      #game state should change to intercept finished if nobody wanted to intercept
      expect(users(:userFour).player.gameboard.reload.current_state).to eql('intercept_finished')

      # pp users(:userOne).player.reload
     
  end

  it 'test if no_intercept does not send board update when only one players has decided not to intercept' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    users(:userOne).player = gameboards(:gameboardFourPlayers).players.first

    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    pp gameboards(:gameboardFourPlayers).players

    stub_connection current_user: users(:userOne)
    subscribe

    player = users(:userOne).player

    player.handcard.ingamedecks.create(card: cards(:buffcard), gameboard: gameboards(:gameboardFourPlayers))

    ## user one intercepts
    expect do
      perform('intercept', {
                unique_card_id: player.handcard.ingamedecks.find_by('card_id=?', cards(:buffcard).id),
                to: 'current_player'
              })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'HANDCARD_UPDATE')
      ).exactly(:once)
      .and have_broadcasted_to("game:#{users(:userOne).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)
    expect(connection.current_user.player.intercept).to be_truthy   

    stub_connection current_user: users(:userThree)
    subscribe

    player = users(:userThree).player

    player.handcard.ingamedecks.create(card: cards(:buffcard), gameboard: gameboards(:gameboardFourPlayers))

    ## user three intercepts
    expect do
      perform('intercept', {
                unique_card_id: player.handcard.ingamedecks.find_by('card_id=?', cards(:buffcard).id),
                to: 'current_player'
              })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'HANDCARD_UPDATE')
      ).exactly(:once)
      .and have_broadcasted_to("game:#{users(:userThree).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

    expect(connection.current_user.player.intercept).to be_truthy   


    stub_connection current_user: users(:userFour)
    subscribe

    # player 4 doesn't want to intercept
    expect do
      perform('no_intercept', {
      player_id: connection.current_user.player.id
    })
    end.to have_broadcasted_to("game:#{users(:userFour).player.gameboard.to_gid_param}")
    .with(
      # should now send broadcast because all 3 players do not want to intercept
      hash_including(type: 'BOARD_UPDATE')
    ).exactly(0).times

    expect(connection.current_user.player.intercept).to be_falsy   

    #game state should change to intercept finished if nobody wanted to intercept
    expect(users(:userFour).player.gameboard.reload.current_state).to eql('intercept_phase')

      # pp users(:userOne).player.reload
     
  end

  it 'test if all players have their default value back after no_intercept' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    users(:userOne).player = gameboards(:gameboardFourPlayers).players.first

    stub_connection current_user: users(:userTwo)
    subscribe

    # player 2 doesn't want to intercept
      perform('no_intercept', {
                player_id: connection.current_user.player.id
              })

      expect(connection.current_user.player.intercept).to be_falsy   

    stub_connection current_user: users(:userThree)
    subscribe

    # player 3 doesn't want to intercept
    perform('no_intercept', {
        player_id: connection.current_user.player.id
      })

    expect(connection.current_user.player.intercept).to be_falsy   

    stub_connection current_user: users(:userFour)
    subscribe

    # player 4 doesn't want to intercept
    perform('no_intercept', {
        player_id: connection.current_user.player.id
      })

      #all players should have the default values back after no_intercept is finished
      expect(users(:userOne).player.reload.intercept).to be_falsy
      expect(users(:userTwo).player.reload.intercept).to be_falsy
      expect(users(:userThree).player.reload.intercept).to be_falsy
      expect(users(:userFour).player.reload.intercept).to be_falsy
     
  end  

  
  it 'all players have default value false in intercept' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    # pp gameboards(:gameboardFourPlayers).players

    expect(users(:userOne).player.intercept).to be_falsy
    expect(users(:userTwo).player.intercept).to be_falsy
    expect(users(:userThree).player.intercept).to be_falsy
    expect(users(:userFour).player.intercept).to be_falsy
  end

end
