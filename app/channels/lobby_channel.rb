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
    delete_old_players

    # search for gameboard with open lobby
    gameboard = Gameboard.find_or_create_by(current_state: LOBBY)

    # create new player
    player = Player.create!(name: current_user.name, gameboard_id: gameboard.id, user: current_user)

    player.init_player(params)

    # TODO: only for testing otherwise false

    @gameboard = gameboard

    # TODO: Remove after testing i guesss
    if params['testplayers'].nil?
      create_dummy_players_for_gameboard(@gameboard)
    else
      create_dummy_players_for_gameboard(@gameboard, params['testplayers'])
    end

    lobbyisfull = @gameboard.players.count > 3

    stream_for @gameboard

    broadcast_to(@gameboard,
                 { type: 'DEBUG', params: { message: "new Player#{current_user.email} conected to the gameboard id: #{@gameboard.id} players in lobby #{@gameboard.reload.players.count}" } })

    if lobbyisfull
      # Lobby is full tell players to start the game
      broadcast_to(@gameboard, { type: 'DEBUG', params: { message: 'Lobby is full start with game subscribe to Player and GameChannel' } })

      @gameboard.initialize_game_board

      gameboard.update!(current_player: player.id)

      broadcast_to(@gameboard, { type: 'START_GAME', params: { game_id: @gameboard.id } })
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def create_dummy_players_for_gameboard(gameboard, number_of_players = 3)
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
    # u1 = User.create(email: "#{x}2@2.at", password: '2', name: "#{x}2", password_confirmation: '2')
    # u2 = User.create(email: "#{x}3@3.at", password: '3', name: "#{x}3", password_confirmation: '3')
    # u3 = User.create(email: "#{x}4@4.at", password: '4', name: "#{x}4", password_confirmation: '4')

    # player1 = Player.create(name: "#{x}2", gameboard: gameboard_test, user: u1)
    # player2 = Player.create(name: "#{x}3", gameboard: gameboard_test, user: u2)
    # player3 = Player.create(name: "#{x}4", gameboard: gameboard_test, user: u3)

    # playercurse1 = Playercurse.create(player: player1)
    # playercurse2 = Playercurse.create(player: player2)
    # playercurse3 = Playercurse.create(player: player3)

    # Handcard.create(player: player1)
    # Handcard.create(player: player2)
    # Handcard.create(player: player3)

    # p1i = Inventory.create(player: player1)
    # p2i = Inventory.create(player: player2)
    # p3i = Inventory.create(player: player3)

    # p1m1 = Monsterone.create(player: player1)
    # p2m1 = Monsterone.create(player: player2)
    # p3m1 = Monsterone.create(player: player3)

    # p1m2 = Monstertwo.create(player: player1)
    # p2m2 = Monstertwo.create(player: player2)
    # p3m2 = Monstertwo.create(player: player3)

    # p1m3 = Monsterthree.create(player: player1)
    # p2m3 = Monsterthree.create(player: player2)
    # p3m3 = Monsterthree.create(player: player3)

    # p1c = Ingamedeck.create(gameboard: gameboard_test, card: Cursecard.first, cardable: playercurse1)
    # p2c = Ingamedeck.create(gameboard: gameboard_test, card: Cursecard.first, cardable: playercurse2)
    # p3c = Ingamedeck.create(gameboard: gameboard_test, card: Cursecard.first, cardable: playercurse3)

    # p1i1 = Ingamedeck.create(gameboard: gameboard_test, card: Itemcard.first, cardable: p1i)
    # p1i2 = Ingamedeck.create(gameboard: gameboard_test, card: Itemcard.first, cardable: p1i)
    # p2i1 = Ingamedeck.create(gameboard: gameboard_test, card: Itemcard.first, cardable: p2i)
    # p2i2 = Ingamedeck.create(gameboard: gameboard_test, card: Itemcard.first, cardable: p2i)
    # p3i1 = Ingamedeck.create(gameboard: gameboard_test, card: Itemcard.first, cardable: p3i)

    # p1m1 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p1m1)
    # p1m2 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p1m2)
    # p1m3 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p1m3)

    # p2m1 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p2m1)
    # p2m2 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p2m2)
    # p2m3 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p2m3)

    # p3m1 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p3m1)
    # p3m2 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p3m2)
    # p3m3 = Ingamedeck.create!(gameboard: gameboard_test, card: Monstercard.first, cardable: p3m3)
  end

  def deliver_error_message(error)
    broadcast_to(@gameboard, { type: 'ERROR', params: { message: error } })
  end

  def delete_old_players
    # search if user is already in a game
    old_players = Player.where('user_id=?', current_user.id)
    old_players.each do |player|
      # if its the current players turn get the next one in line
      old_gameboard = player.gameboard
      if old_gameboard.current_player == player.id
        pp 'player is current_player'
        Gameboard.get_next_player(old_gameboard) if old_gameboard.current_player == player.id
        old_gameboard.reload
        if old_gameboard.current_player == player.id || old_gameboard.players < 3
          old_gameboard.current_player = nil
          old_gameboard.save!
          old_gameboard.destroy!
          next
        end
        # just set current_player to il for now
        # old_gameboard.current_player = nil
      end
      player.destroy!
    end
  end
end
