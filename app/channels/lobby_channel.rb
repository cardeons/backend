# frozen_string_literal: true

class LobbyChannel < ApplicationCable::Channel
  # rescue_from Exception, with: :deliver_error_message

  LOBBY = 'lobby'
  INGAME = 'ingame'

  def subscribed
    if params['initiate']

      lobby = Lobby.create!

      @lobby = lobby

      stream_for @lobby

      current_user.update!(lobby: lobby, oldlobby: lobby.id)

      lobby_users = get_all_users_from_lobby(lobby)
      broadcast_to(@lobby, { type: 'LOBBY_UPDATE', params: { users: lobby_users } })
    elsif params['lobby_id']

      lobby = Lobby.find_by('id = ?', params['lobby_id'])
      @lobby = lobby

      FriendlistChannel.broadcast_to(current_user, { type: 'LOBBY_ERROR', params: { message: 'There is no lobby... please create a new one...' } }) unless lobby

      FriendlistChannel.broadcast_to(current_user, { type: 'LOBBY_ERROR', params: { message: 'Lobby is full...' } }) if lobby.users.count >= 4
      reject if lobby.users.count >= 4

      stream_for @lobby

      current_user.update!(lobby: lobby, oldlobby: lobby.id) if lobby.users.count < 4

      lobby_users = get_all_users_from_lobby(lobby.reload)

      broadcast_to(@lobby, { type: 'LOBBY_UPDATE', params: { users: lobby_users } })
    else
      reject
    end
  end

  def get_all_users_from_lobby(lobby)
    return unless lobby

    lobby.reload
    lobby.users.reload
    lobby_users = []

    lobby.users.each do |user|
      lobby_users.push({ name: user.name, id: user.id })
    end

    lobby_users
  end

  def lobby_invite(data)
    friend = User.find_by('id=?', data['friend'])

    FriendlistChannel.broadcast_to(friend, { type: 'GAME_INVITE', params: { inviter: current_user.id, inviter_name: current_user.name, lobby_id: current_user.lobby.id } })
  end

  def add_monster(data)
    current_user.monsterone.blank? && current_user.update!(monsterone: data['monster_id']) && return
    current_user.monstertwo.blank? && current_user.update!(monstertwo: data['monster_id']) && return
    current_user.monsterthree.blank? && current_user.update!(monsterthree: data['monster_id']) && return
  end

  def remove_monster(data)
    current_user.monsterone == data['monster_id'] && current_user.update!(monsterone: nil) && return
    current_user.monstertwo == data['monster_id'] && current_user.update!(monstertwo: nil) && return
    current_user.monsterthree == data['monster_id'] && current_user.update!(monsterthree: nil) && return
  end

  def start_lobby_queue(data)
    lobby = current_user.lobby

    delete_old_players

    gameboard = Gameboard.find_or_create_by!(current_state: :lobby)

    gameboard = Gameboard.create!(current_state: :lobby) if lobby.users.reload.count > (4 - gameboard.players.reload.count)
    @gameboard = gameboard

    broadcast_to(@lobby, { type: 'START_QUEUE', params: { game_id: @gameboard.id } })

    lobby.users.each do |user|
      Player.create!(name: user.name, gameboard_id: gameboard.id, user: user)

      player = user.player

      player.init_player(user)

      # player.init_player(params)
      # gameboard = current_user.player.gameboard

      # gameboard.update!(current_player: player)
      # Should only be usable if ENV is set
      ENV['DEV_TOOL_ENABLED'] == 'enabled' && create_dummy_players_for_gameboard(@gameboard, data['testplayers'])

      lobbyisfull = @gameboard.players.count > 3

      user.update!(lobby: nil, oldlobby: nil)

      broadcast_to(@lobby,
                   { type: 'DEBUG', params: { message: "new Player#{current_user.email} conected to the gameboard id: #{@gameboard.id} players in lobby #{@gameboard.reload.players.count}" } })

      next unless lobbyisfull

      lobby.destroy!

      # Lobby is full tell players to start the game
      broadcast_to(@lobby, { type: 'DEBUG', params: { message: 'Lobby is full start with game subscribe to Player and GameChannel' } })

      @gameboard.initialize_game_board

      broadcast_to(@lobby, { type: 'START_GAME', params: { game_id: @gameboard.id } })
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    # kann des probleme machen beim reload? weil man dann keine params mehr hat?? :thinking:
    # current_user.update(lobby: nil)
    lobby = current_user.lobby
    current_user.update!(monsterone: nil, monstertwo: nil, monsterthree: nil, lobby: nil)

    lobby_users = get_all_users_from_lobby(lobby)
    broadcast_to(@lobby, { type: 'LOBBY_UPDATE', params: { users: lobby_users } })
    lobby.destroy if lobby && (lobby.reload.users.reload.count == 0)

    return unless @gameboard

    if @gameboard.reload.lobby?
      current_user.player.destroy!
      # pp current_user.player.id
      # Player.destroy(current_user.player.id)
      # pp current_user.player.reload
      broadcast_to(@lobby, { type: 'DEBUG', params: { message: 'User left the lobby and got destroyed' } })
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
    broadcast_to(@lobby, { type: 'ERROR', params: { message: error } })
  end

  def delete_old_players
    # search if user is already in a game
    old_players = Player.where('user_id=?', current_user.id)
    old_players.each do |player|
      # if its the current players turn get the next one in line
      old_gameboard = player.gameboard
      if old_gameboard.current_player == player
        Gameboard.get_next_player(old_gameboard) if old_gameboard.current_player == player
        old_gameboard.reload
        if old_gameboard.current_player == player || old_gameboard.players.count < 3
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
