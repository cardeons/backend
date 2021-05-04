# frozen_string_literal: true

class LobbyChannel < ApplicationCable::Channel
  # rescue_from Exception, with: :deliver_error_message

  LOBBY = 'lobby'
  INGAME = 'ingame'

  def subscribed
    # access current user with current_user

    # check if there is not a player with this user
    ## read find or create by for simpler solution
    # if Player.find_by(user_id: current_user.id)
    #   # transmit {type: "error", params:{message: "user is already playing in #{player.gameboard_id}"}}
    #   player = Player.find_by(user_id: current_user.id)
    #   Gameboard.find(player.gameboard_id).destroy
    #   createNewTestGame
    #   # reject
    # end

    # remove player from old gameboard
    # delete_old_players

    # search for gameboard with open lobby
    # gameboard = Gameboard.find_or_create_by(current_state: LOBBY)

    # create new player
    # player = Player.create!(name: current_user.name, gameboard_id: gameboard.id, user: current_user)

    player = current_user.player

    player.init_player(params)

    # player.init_player(params)
    gameboard = current_user.player.gameboard

    gameboard.update!(current_player: player)

    @gameboard = gameboard

    # Should only be usable if ENV is set
    ENV['DEV_TOOL_ENABLED'] == 'enabled' && create_dummy_players_for_gameboard(@gameboard, params['testplayers'])

    lobbyisfull = @gameboard.players.count > 3

    stream_for @gameboard

    broadcast_to(@gameboard,
                 { type: 'DEBUG', params: { message: "new Player#{current_user.email} conected to the gameboard id: #{@gameboard.id} players in lobby #{@gameboard.reload.players.count}" } })

    if lobbyisfull
      # Lobby is full tell players to start the game
      broadcast_to(@gameboard, { type: 'DEBUG', params: { message: 'Lobby is full start with game subscribe to Player and GameChannel' } })

      @gameboard.initialize_game_board

      broadcast_to(@gameboard, { type: 'START_GAME', params: { game_id: @gameboard.id } })
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    if @gameboard.reload.lobby?
      current_user.player.destroy!
      # pp current_user.player.id
      # Player.destroy(current_user.player.id)
      # pp current_user.player.reload
      broadcast_to(@gameboard, { type: 'DEBUG', params: { message: 'User left the lobby and got destroyed' } })
    end
  end

  private

  def create_dummy_players_for_gameboard(gameboard, number_of_players)
    # number of players could be nil if a user deletes it from the form
    number_of_players = 0 if number_of_players.nil?

    max_players = 4
    gameboard_test = gameboard

    ## never add more than 4 players to the game
    number_of_players = max_players - gameboard_test.players.count if (gameboard_test.players.count + number_of_players) > 4

    (1..number_of_players).each do
      x = rand(1..1_000_000)
      u1 = User.create!(email: "#{x}2@2.at", password: '2', name: "#{x}2", password_confirmation: '2')
      player1 = Player.create!(name: "#{x}2", gameboard: gameboard_test, user: u1)
      playercurse1 = Playercurse.create!(player: player1)
      Handcard.create!(player: player1)
      p1i = Inventory.create!(player: player1)
      p1m1 = Monsterone.create!(player: player1)
      p1m2 = Monstertwo.create!(player: player1)
      p1m3 = Monsterthree.create!(player: player1)
      # pp Cursecard.all
      # p1c = Ingamedeck.create!(gameboard: gameboard_test, card: Cursecard.first, cardable: playercurse1)
      p1i1 = Ingamedeck.create!(gameboard: gameboard_test, card: Itemcard.first, cardable: p1i)
      p1i2 = Ingamedeck.create!(gameboard: gameboard_test, card: Itemcard.first, cardable: p1i)
    end
  end

  def deliver_error_message(error)
    broadcast_to(@gameboard, { type: 'ERROR', params: { message: error } })
  end
end
