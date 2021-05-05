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
    connection.current_user.player.gameboard.update(current_player: players(:singleplayer))

    expect do
      perform('flee', {})
    end
      .to have_broadcasted_to("game:#{connection.current_user.player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'FLEE')
      ).exactly(:once)
      .and have_broadcasted_to("game:#{connection.current_user.player.gameboard.to_gid_param}")
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

  it 'test if no_interception sends board update when all players have decided not to intercept' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    users(:userOne).player = gameboards(:gameboardFourPlayers).players.first

    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    stub_connection current_user: users(:userTwo)
    subscribe

    # player 2 doesn't want to intercept
    perform('no_interception', {
              player_id: connection.current_user.player.id
            })

    expect(connection.current_user.player.intercept).to be_falsy

    stub_connection current_user: users(:userThree)
    subscribe

    # player 3 doesn't want to intercept
    perform('no_interception', {
              player_id: connection.current_user.player.id
            })

    expect(connection.current_user.player.intercept).to be_falsy

    stub_connection current_user: users(:userFour)
    subscribe

    # player 4 doesn't want to intercept
    expect do
      perform('no_interception', {
                player_id: connection.current_user.player.id
              })
    end.to have_broadcasted_to("game:#{users(:userFour).player.gameboard.to_gid_param}")
      .with(
        # should now send broadcast because all 3 players do not want to intercept
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(1).times

    # game state should change to intercept finished if nobody wanted to intercept
    expect(users(:userFour).player.gameboard.reload.current_state).to eql('intercept_finished')

    # pp users(:userOne).player.reload
  end

  it 'test if no_interception does not send board update when only one players has decided not to intercept' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    users(:userOne).player = gameboards(:gameboardFourPlayers).players.first

    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

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
      perform('no_interception', {
                player_id: connection.current_user.player.id
              })
    end.to have_broadcasted_to("game:#{users(:userFour).player.gameboard.to_gid_param}")
      .with(
        # should now send broadcast because all 3 players do not want to intercept
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

    expect(connection.current_user.player.intercept).to be_falsy

    # game state should change to intercept finished if nobody wanted to intercept
    expect(users(:userFour).player.gameboard.reload.current_state).to eql('intercept_phase')

    # pp users(:userOne).player.reload
  end

  it 'test if all players have their default value back after no_interception' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    users(:userOne).player = gameboards(:gameboardFourPlayers).players.first

    stub_connection current_user: users(:userTwo)
    subscribe

    # player 2 doesn't want to intercept
    perform('no_interception', {
              player_id: connection.current_user.player.id
            })

    expect(connection.current_user.player.intercept).to be_falsy

    stub_connection current_user: users(:userThree)
    subscribe

    # player 3 doesn't want to intercept
    perform('no_interception', {
              player_id: connection.current_user.player.id
            })

    expect(connection.current_user.player.intercept).to be_falsy

    stub_connection current_user: users(:userFour)
    subscribe

    # player 4 doesn't want to intercept
    perform('no_interception', {
              player_id: connection.current_user.player.id
            })

    # all players should have the default values back after no_intercept is finished
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

  # it 'test if gameboard updates helping_player asked_help and shared_reward if help is asked' do
  #   gameboards(:gameboardFourPlayers).initialize_game_board
  #   gameboards(:gameboardFourPlayers).players.each(&:init_player)
  #   # assign player to this user
  #   users(:one).player = gameboards(:gameboardFourPlayers).players.first
  #   users(:two).player = gameboards(:gameboardFourPlayers).players.last

  #   stub_connection current_user: users(:two)
  #   subscribe
  #   stub_connection current_user: users(:one)
  #   subscribe

  #   player = users(:one).player

  #   player.handcard.ingamedecks.create(card: cards(:itemcard), gameboard: gameboards(:gameboardFourPlayers))

  #   expect do
  #     perform('draw_door_card', {})
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(:once)

  #   expect do
  #     perform('help_call', {
  #               helping_player_id: 3,
  #               helping_shared_rewards: 2
  #             })
  #   end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.helping_user))
  #     .with(
  #       hash_including(type: 'ASK_FOR_HELP')
  #     ).exactly(:once)
  #     .and have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       # there should be no broadcast since this action was invalid
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(0).times

  #   expect(gameboards(:gameboardFourPlayers).asked_help).to be_truthy
  #   expect(gameboards(:gameboardFourPlayers).shared_reward).to eql(2)
  #   expect(gameboards(:gameboardFourPlayers).helping_player).to eql(3)
  # end

  # it 'test if gameboard updates player_atk if help is given' do
  #   gameboards(:gameboardFourPlayers).initialize_game_board
  #   gameboards(:gameboardFourPlayers).players.each(&:init_player)
  #   # assign player to this user
  #   users(:one).player = gameboards(:gameboardFourPlayers).players.first

  #   stub_connection current_user: users(:one)
  #   subscribe

  #   player = users(:one).player

  #   player.handcard.ingamedecks.create(card: cards(:itemcard), gameboard: gameboards(:gameboardFourPlayers))

  #   old_playeratk = gameboards(:gameboardFourPlayers).player_atk

  #   expect do
  #     perform('draw_door_card', {})
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(:once)

  #   expect do
  #     perform('help_call', {
  #               helping_player_id: 3,
  #               helping_shared_rewards: 2
  #             })
  #   end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
  #     .with(
  #       hash_including(type: 'ASK_FOR_HELP')
  #     ).exactly(:once)
  #     .and have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       # there should be no broadcast since this action was invalid
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(0).times

  #   expect do
  #     perform('answer_help_call', {
  #               help: true
  #             })
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       # there should be no broadcast since this action was invalid
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(:once)

  #   expect(gameboards(:gameboardFourPlayers).helping_player_atk).to_not eql(0)
  # end

  # it 'test if gameboard does not update player_atk if help is not given' do
  #   gameboards(:gameboardFourPlayers).initialize_game_board
  #   gameboards(:gameboardFourPlayers).players.each(&:init_player)
  #   # assign player to this user
  #   users(:one).player = gameboards(:gameboardFourPlayers).players.first

  #   stub_connection current_user: users(:one)
  #   subscribe

  #   player = users(:one).player

  #   player.handcard.ingamedecks.create(card: cards(:itemcard), gameboard: gameboards(:gameboardFourPlayers))

  #   old_playeratk = gameboards(:gameboardFourPlayers).player_atk

  #   expect do
  #     perform('draw_door_card', {})
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(:once)

  #   expect do
  #     perform('help_call', {
  #               helping_player_id: 3,
  #               helping_shared_rewards: 2
  #             })
  #   end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
  #     .with(
  #       hash_including(type: 'ASK_FOR_HELP')
  #     ).exactly(:once)
  #     .and have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       # there should be no broadcast since this action was invalid
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(0).times

  #   expect do
  #     perform('answer_help_call', {
  #               help: false
  #             })
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       # there should be no broadcast since this action was invalid
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(:once)

  #   expect(gameboards(:gameboardFourPlayers).helping_player_atk).to eql(0)
  # end

  # it 'test if rewards shared' do
  #   gameboards(:gameboardFourPlayers).initialize_game_board
  #   gameboards(:gameboardFourPlayers).players.each(&:init_player)
  #   # assign player to this user
  #   users(:one).player = gameboards(:gameboardFourPlayers).players.first
  #   gameboards(:gameboardFourPlayers).update(current_player: users(:one).player.id)
  #   stub_connection current_user: users(:one)
  #   subscribe

  #   player = users(:one).player

  #   Player.find(3).update(attack: 999)

  #   expect do
  #     perform('draw_door_card', {})
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(:once)

  #   expect do
  #     perform('help_call', {
  #               helping_player_id: 3,
  #               helping_shared_rewards: 1
  #             })
  #   end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
  #     .with(
  #       hash_including(type: 'ASK_FOR_HELP')
  #     ).exactly(:once)
  #     .and have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(0).times

  #   expect do
  #     perform('answer_help_call', {
  #               help: true
  #             })
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")

  #   expect do
  #     perform('attack', {})
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(:once)

  #   expect(Player.find(3).handcard.ingamedecks.size).to eql(6)
  #   expect(player.reload.handcard.ingamedecks.size).to eql(5 + (gameboards(:gameboardFourPlayers).reload.rewards_treasure - gameboards(:gameboardFourPlayers).reload.shared_reward))
  # end

  # it 'test if rewards not shared if help is not given' do
  #   gameboards(:gameboardFourPlayers).initialize_game_board
  #   gameboards(:gameboardFourPlayers).players.each(&:init_player)
  #   # assign player to this user
  #   users(:one).player = gameboards(:gameboardFourPlayers).players.first
  #   gameboards(:gameboardFourPlayers).update(current_player: users(:one).player.id)
  #   stub_connection current_user: users(:one)
  #   subscribe

  #   player = users(:one).player

  #   player.update(level: 999)

  #   expect do
  #     perform('draw_door_card', {})
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(:once)

  #   expect do
  #     perform('help_call', {
  #               helping_player_id: 3,
  #               helping_shared_rewards: 1
  #             })
  #   end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
  #     .with(
  #       hash_including(type: 'ASK_FOR_HELP')
  #     ).exactly(:once)
  #     .and have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(0).times

  #   expect do
  #     perform('answer_help_call', {
  #               help: false
  #             })
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(:once)

  #   expect do
  #     perform('attack', {})
  #   end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
  #     .with(
  #       hash_including(type: 'BOARD_UPDATE')
  #     ).exactly(:once)

  #   expect(Player.find(3).handcard.ingamedecks.size).to eql(5)
  #   expect(player.reload.handcard.ingamedecks.size).to eql(5 + gameboards(:gameboardFourPlayers).reload.rewards_treasure)
  # end

  it 'test if throws error if shared rewards are too high' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first
    gameboards(:gameboardFourPlayers).update(current_player: users(:one).player)
    stub_connection current_user: users(:one)
    subscribe

    expect do
      perform('draw_door_card', {})
    end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

    expect do
      perform('help_call', {
                helping_player_id: 3,
                helping_shared_rewards: 100
              })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'ERROR')
      ).exactly(:once)
      .and have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(0).times
  end

  it 'test if throws error if already asked for help' do
    # gameboards(:gameboardFourPlayers).initialize_game_board
    # gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # # assign player to this user
    # users(:one).player = gameboards(:gameboardFourPlayers).players.first
    # gameboards(:gameboardFourPlayers).update(current_player: 1)
    # stub_connection current_user: users(:one)
    # subscribe

    # expect do
    #   perform('draw_door_card', {})
    # end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
    #   .with(
    #     hash_including(type: 'BOARD_UPDATE')
    #   ).exactly(:once)

    # expect do
    #   perform('help_call', {
    #             helping_player_id: 3,
    #             helping_shared_rewards: 1
    #           })
    # end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
    #   .with(
    #     hash_including(type: 'ASK_FOR_HELP')
    #   ).exactly(:once)

    # # expect do
    # #   perform('help_call', {
    # #             helping_player_id: 3,
    # #             helping_shared_rewards: 1
    # #           })
    # # end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
    # #   .with(
    # #     hash_including(type: 'ERROR')
    # #   ).exactly(:once)
  end

  it 'test if throws error if player is not current_player for help' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first
    gameboards(:gameboardFourPlayers).update(current_player: players(:playerFour))
    stub_connection current_user: users(:one)
    subscribe

    expect do
      perform('draw_door_card', {})
    end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

    expect do
      perform('help_call', {
                helping_player_id: 3,
                helping_shared_rewards: 1
              })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'ERROR')
      ).exactly(:once)
  end

  it 'test if throws error if player curses someone without a cursecard' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first
    stub_connection current_user: users(:one)
    subscribe

    ingamedeck = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:test), cardable: users(:one).player.handcard)

    expect do
      perform('curse_player', {
                to: 2,
                unique_card_id: ingamedeck.id
              })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'ERROR')
      ).exactly(:once)

    expect(ingamedeck.cardable).to eql(users(:one).player.handcard)
  end

  it 'test if curse on player if cursed' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first
    stub_connection current_user: users(:one)
    subscribe

    ingamedeck = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard), cardable: users(:one).player.handcard)

    expect do
      perform('curse_player', {
                to: 2,
                unique_card_id: ingamedeck.id
              })
    end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

    expect(ingamedeck.reload.cardable).to eql(users(:one).player.playercurse)
  end

  it 'test if curse in graveyard and activated if cursed with instant curse' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first
    stub_connection current_user: users(:one)
    subscribe

    users(:one).player.update(level: 4)
    ingamedeck = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard2), cardable: users(:one).player.handcard)

    expect do
      perform('curse_player', {
                to: 2,
                unique_card_id: ingamedeck.id
              })
    end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

    expect(users(:one).player.reload.level).to eql(3)
    expect(ingamedeck.reload.cardable).to eql(gameboards(:gameboardFourPlayers).graveyard)
  end

  it 'test if gains level if cursed with levelcard' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first
    stub_connection current_user: users(:one)
    subscribe

    ingamedeck = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:levelcard), cardable: users(:one).player.handcard)

    expect do
      perform('curse_player', {
                to: 2,
                unique_card_id: ingamedeck.id
              })
    end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

    expect(users(:one).player.reload.level).to eql(2)
  end

  it 'test if bad_things happen when you can not flee' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first
    stub_connection current_user: users(:one)
    subscribe

    ingamedeck = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:levelcard), cardable: users(:one).player.handcard)

    expect do
      perform('curse_player', {
                to: 2,
                unique_card_id: ingamedeck.id
              })
    end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'BOARD_UPDATE')
      ).exactly(:once)

    expect(users(:one).player.reload.level).to eql(2)
  end

  it 'succesfull attack triggers WIN broadcast if player is now exactly level 5' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    stub_connection current_user: users(:userFour)
    subscribe

    users(:userFour).player.update!(attack: 999)
    users(:userFour).player.update!(level: 4)

    # set centercard with one level reward because srand always chooses a card with 2
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: gameboards(:gameboardFourPlayers).centercard)

    expect do
      perform('attack', {})
    end.to have_broadcasted_to("game:#{users(:userFour).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'WIN')
      ).exactly(:once)

    expect(users(:userFour).player.reload.level).to eql(5)
    expect(gameboards(:gameboardFourPlayers).reload.current_state).to eql('game_won')
  end

  it 'succesfull attack triggers WIN broadcast if player is higher than level 5 because monsters can give 2 levels' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    stub_connection current_user: users(:userFour)
    subscribe

    users(:userFour).player.update!(attack: 999)
    users(:userFour).player.update!(level: 4)

    # simulate centercard with double level reward
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard10), cardable: gameboards(:gameboardFourPlayers).centercard)

    expect do
      perform('attack', {})
    end.to have_broadcasted_to("game:#{users(:userFour).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'WIN')
      ).exactly(:once)

    expect(users(:userFour).player.reload.level).to eql(6)
    expect(gameboards(:gameboardFourPlayers).reload.current_state).to eql('game_won')
  end

  it 'user gets a new monster' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    stub_connection current_user: users(:userFour)
    subscribe

    users(:userFour).player.update!(attack: 999)
    users(:userFour).player.update!(level: 4)

    # set centercard with one level reward because srand always chooses a card with 2
    Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard9), cardable: gameboards(:gameboardFourPlayers).centercard)

    expect do
      perform('attack', {})
    end.to have_broadcasted_to("game:#{users(:userFour).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'WIN')
      ).exactly(:once)

    expect(users(:userFour).player.reload.level).to eql(5)
    expect(users(:userFour).cards.size).to eql(1)
  end

  it 'user gets a new monster if he already owns the first' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    stub_connection current_user: users(:userFour)
    subscribe

    users(:userFour).player.update!(attack: 999)
    users(:userFour).player.update!(level: 4)

    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    users(:userFour).cards << Monstercard.find(9)

    perform('attack', {})

    expect(users(:userFour).cards.size).to eql(2)
  end

  it 'player can only play a monster if its his turn' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    gameboards(:gameboardFourPlayers).update!(current_player: users(:userFour).player)

    stub_connection current_user: users(:userThree)
    subscribe

    ingamedeck = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:monstercard), cardable: users(:userThree).player.handcard)

    # expects that it is not user three turn
    expect do
      perform('play_monster', { unique_card_id: ingamedeck.id })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'ERROR', params: { message: 'Only the the Player whos turn it is can play a Monster' })
      ).exactly(:once)
  end

  it 'player receives error if using something else than a monstercard' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    # set myself as current player
    gameboards(:gameboardFourPlayers).update!(current_player: users(:userThree).player)

    stub_connection current_user: users(:userThree)
    subscribe

    ingamedeck = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:buffcard), cardable: users(:userThree).player.handcard)

    # expects that it is not user three turn
    expect do
      perform('play_monster', { unique_card_id: ingamedeck.id })
    end.to have_broadcasted_to(PlayerChannel.broadcasting_for(connection.current_user))
      .with(
        hash_including(type: 'ERROR', params: { message: "You can't fight against this card!" })
      ).exactly(:once)
  end

  it 'unsubscribe' do
    # gameboards(:gameboardFourPlayers).initialize_game_board
    # gameboards(:gameboardFourPlayers).players.each(&:init_player)

    # player = users(:userFour).player

    # ## users subscribe
    # stub_connection current_user: users(:userFour)
    # subscribe

    # stub_connection current_user: users(:userThree)
    # subscribe

    # stub_connection current_user: users(:userTwo)
    # subscribe

    # ## users unsubscribe
    # # stub_connection current_user: users(:userFour)

    # gameboards(:gameboardFourPlayers).update(current_player: users(:userFour).player.id)

    # pp gameboards(:gameboardFourPlayers).players
    # pp 'first unsubscribe'

    # unsubscribe

    # expect(users(:userFour).reload.player).to be_falsy
    # expect(gameboards(:gameboardFourPlayers).reload.players.size).to eql(2)

    # stub_connection current_user: users(:userThree)
    # unsubscribe

    # pp 'second unsubscribe'

    # expect(users(:userThree).reload.player).to be_falsy
    # expect(gameboards(:gameboardFourPlayers).reload.players.size).to eql(1)

    # stub_connection current_user: users(:userTwo)
    # unsubscribe

    # pp 'third unsubscribe'

    # expect(users(:userTwo).reload.player).to be_falsy
    # expect(gameboards(:gameboardFourPlayers).reload.players.size).to eql(0)

    # pp '--------------------'

    # # pp users(:userFour).reload.player

    # player is still referenced in gameboard, gets deleted
    # end
  end

  it 'test if buffcards get removed after attack is over' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    stub_connection current_user: users(:userFour)
    subscribe

    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    player = gameboards(:gameboardFourPlayers).current_player
    unique_card = player.handcard.ingamedecks.create(card: cards(:buffcard), gameboard: gameboards(:gameboardFourPlayers))
    unique_card2 = player.handcard.ingamedecks.create(card: cards(:buffcard3), gameboard: gameboards(:gameboardFourPlayers))

    ## buff monster two times
    perform('intercept', {
              unique_card_id: player.handcard.ingamedecks.find_by('id=?', unique_card.id),
              to: 'center_card'
            })

    perform('intercept', {
              unique_card_id: player.handcard.ingamedecks.find_by('id=?', unique_card2.id),
              to: 'center_card'
            })

    unique_card3 = player.handcard.ingamedecks.create(card: cards(:buffcard2), gameboard: gameboards(:gameboardFourPlayers))
    unique_card4 = player.handcard.ingamedecks.create(card: cards(:buffcard5), gameboard: gameboards(:gameboardFourPlayers))

    ## buff player two times
    perform('intercept', {
              unique_card_id: player.handcard.ingamedecks.find_by('id=?', unique_card3.id),
              to: 'current_player'
            })

    perform('intercept', {
              unique_card_id: player.handcard.ingamedecks.find_by('id=?', unique_card4.id),
              to: 'current_player'
            })

    perform('attack', {})

    expect(Ingamedeck.find_by('id=?', unique_card.id).cardable_type).to eql('Graveyard')
    expect(Ingamedeck.find_by('id=?', unique_card2.id).cardable_type).to eql('Graveyard')
    expect(Ingamedeck.find_by('id=?', unique_card3.id).cardable_type).to eql('Graveyard')
    expect(Ingamedeck.find_by('id=?', unique_card4.id).cardable_type).to eql('Graveyard')
  end

  it 'test if buffcards get removed after flee is over' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    stub_connection current_user: users(:userFour)
    subscribe

    Gameboard.draw_door_card(gameboards(:gameboardFourPlayers))

    player = gameboards(:gameboardFourPlayers).current_player
    unique_card = player.handcard.ingamedecks.create(card: cards(:buffcard), gameboard: gameboards(:gameboardFourPlayers))
    unique_card2 = player.handcard.ingamedecks.create(card: cards(:buffcard3), gameboard: gameboards(:gameboardFourPlayers))

    ## buff monster two times
    perform('intercept', {
              unique_card_id: player.handcard.ingamedecks.find_by('id=?', unique_card.id),
              to: 'center_card'
            })

    perform('intercept', {
              unique_card_id: player.handcard.ingamedecks.find_by('id=?', unique_card2.id),
              to: 'center_card'
            })

    unique_card3 = player.handcard.ingamedecks.create(card: cards(:buffcard2), gameboard: gameboards(:gameboardFourPlayers))
    unique_card4 = player.handcard.ingamedecks.create(card: cards(:buffcard5), gameboard: gameboards(:gameboardFourPlayers))

    ## buff player two times
    perform('intercept', {
              unique_card_id: player.handcard.ingamedecks.find_by('id=?', unique_card3.id),
              to: 'current_player'
            })

    perform('intercept', {
              unique_card_id: player.handcard.ingamedecks.find_by('id=?', unique_card4.id),
              to: 'current_player'
            })

    perform('flee', {})

    expect(Ingamedeck.find_by('id=?', unique_card.id).cardable_type).to eql('Graveyard')
    expect(Ingamedeck.find_by('id=?', unique_card2.id).cardable_type).to eql('Graveyard')
    expect(Ingamedeck.find_by('id=?', unique_card3.id).cardable_type).to eql('Graveyard')
    expect(Ingamedeck.find_by('id=?', unique_card4.id).cardable_type).to eql('Graveyard')
  end

  it 'user is set to inactive if he unsubscribes from the game_channel' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)

    stub_connection current_user: users(:userFour)
    subscribe

    # player is set to inactive = false on subscribe
    expect(users(:userFour).player.inactive).to be_falsy
    unsubscribe

    # player is set to inactive = true on unsubscribe
    expect(users(:userFour).player.inactive).to be_truthy
  end

  it 'dev action gets right next player' do
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    gameboards(:gameboardFourPlayers).initialize_game_board

    stub_connection current_user: users(:userOne)
    subscribe

    ENV['DEV_TOOL_ENABLED'] = 'enabled'

    perform('develop_set_next_player_as_current_player', {})
    expect(gameboards(:gameboardFourPlayers).reload.current_player).to eql(gameboards(:gameboardFourPlayers).players.first)

    perform('develop_set_next_player_as_current_player', {})
    expect(gameboards(:gameboardFourPlayers).reload.current_player).to eql(gameboards(:gameboardFourPlayers).players.second)

    perform('develop_set_next_player_as_current_player', {})
    expect(gameboards(:gameboardFourPlayers).reload.current_player).to eql(gameboards(:gameboardFourPlayers).players.third)
  end

  it 'test if curse log gets sent after activating cursecard' do
    gameboards(:gameboardFourPlayers).initialize_game_board
    gameboards(:gameboardFourPlayers).players.each(&:init_player)
    # assign player to this user
    users(:one).player = gameboards(:gameboardFourPlayers).players.first
    stub_connection current_user: users(:one)
    subscribe

    users(:one).player.update(level: 4)
    ingamedeck = Ingamedeck.create!(gameboard: gameboards(:gameboardFourPlayers), card: cards(:cursecard2), cardable: users(:one).player.handcard)

    expect do
      perform('curse_player', {
                to: 2,
                unique_card_id: ingamedeck.id
              })
    end.to have_broadcasted_to("game:#{users(:one).player.gameboard.to_gid_param}")
      .with(
        hash_including(type: 'CURSE_LOG')
      )
  end
end
