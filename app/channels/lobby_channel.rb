# frozen_string_literal: true

class LobbyChannel < ApplicationCable::Channel
  rescue_from Exception, with: :deliver_error_message

  def subscribed
    awaiting_players = 'awaiting_players'

    # access current user with current_user
    puts current_user

    # check if there is not a player with this user
    ## read find or create by for simpler solution
    if player = Player.find(user_id: current_user.id)
      # transmit {type: "error", params:{message: "user is already playing in #{player.gameboard_id}"}}
      reject
    end

    # search for gameboard with open lobby
    unless gameboard = Gameboard.find_by(current_state: awaiting_players)
      gameboard = Gameboard.create(current_state: awaiting_players)
    end

    # create new player
    player = Player.new(gameboard_id: gameboard.id)
    player.user = current_user
    player.save!

    handcard = Handcard.create(player_id: player.id) unless player.handcard
    Ingamedeck.create(card_id: params[:monsterone], gameboard: gameboard, cardable: handcard)

    lobbyisfull = false

    if gameboard.players.count > 3
      gameboard.current_state = 'started'
      ### add add the starting user
      gameboard.current_player = gameboard.players.first
      gameboard.save
      lobbyisfull = true
    end

    # hopefully it is the same after saving?
    @gameboard = gameboard

    stream_for @gameboard

    broadcast_to(@gameboard, { type: 'DEBUG', params: { message: "new Player#{current_user.email} conected to the gameboard id: #{@gameboard.id} players in lobby #{@gameboard.players.count}" } })

    if lobbyisfull
      # Lobby is full tell players to start the game
      broadcast_to(@gameboard, { type: 'DEBUG', params: { message: 'Lobby is full start with game subscribe to Player and GameChannel' } })

      Gameboard.initialize_gameBoard(@gameboard)
      broadcast_to(@gameboard, { type: 'START_GAME', params: { game_id: @gameboard.id } })
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def deliver_error_message(e)
    broadcast_to(@gameboard, { type: 'error', params: { message: e } })
  end
end
