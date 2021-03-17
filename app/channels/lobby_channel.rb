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

    # search for gameboard with open lobby
    gameboard = Gameboard.find_by(current_state: LOBBY)
    gameboard ||= Gameboard.create(current_state: LOBBY)

    # create new player
    player = Player.create(name: current_user.name, gameboard_id: gameboard.id, user: current_user)
    
    handcard = Handcard.create(player_id: player.id) unless player.handcard

    # add monsterone to handcard of player
    Ingamedeck.create(card_id: params[:monsterone], gameboard: gameboard, cardable: handcard) if params[:monsterone]
    Ingamedeck.create(card_id: params[:monstertwo], gameboard: gameboard, cardable: handcard) if params[:monstertwo]
    Ingamedeck.create(card_id: params[:monsterthree], gameboard: gameboard, cardable: handcard) if params[:monsterthree]

    lobbyisfull = false

    if gameboard.players.count > 3
      # gameboard.current_state = 'started'
      # gameboard.current_player = gameboard.players.first
      # gameboard.save

      ### add add the starting user
      lobbyisfull = true
    end

    # hopefully it is the same after saving?
    @gameboard = gameboard

    stream_for @gameboard

    broadcast_to(@gameboard, { type: 'DEBUG', params: { message: "new Player#{current_user.email} conected to the gameboard id: #{@gameboard.id} players in lobby #{@gameboard.players.count}" } })

    if lobbyisfull
      # Lobby is full tell players to start the game
      broadcast_to(@gameboard, { type: 'DEBUG', params: { message: 'Lobby is full start with game subscribe to Player and GameChannel' } })

      Gameboard.initialize_game_board(@gameboard)
      broadcast_to(@gameboard, { type: 'START_GAME', params: { game_id: @gameboard.id } })

      # TODO: Remove after testing i guesss
      createNewTestGame
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def createNewTestGame
    gameboard_test = Gameboard.create(current_state: INGAME, player_atk: 5)
    x = rand(1..1_000_000)
    u1 = User.create(email: "#{x}2@2.at", password: '2', name: "#{x}2", password_confirmation: '2')
    u2 = User.create(email: "#{x}3@3.at", password: '3', name: "#{x}3", password_confirmation: '3')
    u3 = User.create(email: "#{x}4@4.at", password: '4', name: "#{x}4", password_confirmation: '4')

    player1 = Player.create(name: "#{x}2", gameboard: gameboard_test, user: u1)
    player2 = Player.create(name: "#{x}3", gameboard: gameboard_test, user: u2)
    player3 = Player.create(name: "#{x}4", gameboard: gameboard_test, user: u3)

    playercurse1 = Playercurse.create(player: player1)
    playercurse2 = Playercurse.create(player: player2)
    playercurse3 = Playercurse.create(player: player3)

    p1i = Inventory.create(player: player1)
    p2i = Inventory.create(player: player2)
    p3i = Inventory.create(player: player3)

    p1m1 = Monsterone.create(player: player1)
    p2m1 = Monsterone.create(player: player2)
    p3m1 = Monsterone.create(player: player3)

    p1m2 = Monstertwo.create(player: player1)
    p2m2 = Monstertwo.create(player: player2)
    p3m2 = Monstertwo.create(player: player3)

    p1m3 = Monsterthree.create(player: player1)
    p2m3 = Monsterthree.create(player: player2)
    p3m3 = Monsterthree.create(player: player3)

    p1c = Ingamedeck.create(gameboard: gameboard_test, card: Cursecard.first, cardable: playercurse1)
    p2c = Ingamedeck.create(gameboard: gameboard_test, card: Cursecard.first, cardable: playercurse2)
    p3c = Ingamedeck.create(gameboard: gameboard_test, card: Cursecard.first, cardable: playercurse3)

    p1i1 = Ingamedeck.create(gameboard: gameboard_test, card: Itemcard.first, cardable: p1i)
    p1i2 = Ingamedeck.create(gameboard: gameboard_test, card: Itemcard.first, cardable: p1i)
    p2i1 = Ingamedeck.create(gameboard: gameboard_test, card: Itemcard.first, cardable: p2i)
    p2i2 = Ingamedeck.create(gameboard: gameboard_test, card: Itemcard.first, cardable: p2i)
    p3i1 = Ingamedeck.create(gameboard: gameboard_test, card: Itemcard.first, cardable: p3i)

    p1m1 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p1m1)
    p1m2 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p1m2)
    p1m3 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p1m3)

    p2m1 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p2m1)
    p2m2 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p2m2)
    p2m3 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p2m3)

    p3m1 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p3m1)
    p3m2 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p3m2)
    p3m3 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p3m3)
  end

  def deliver_error_message(error)
    broadcast_to(@gameboard, { type: 'ERROR', params: { message: error } })
  end
end
