class GamesocketChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  def subscribed

    awaiting_players = "awaiting_players"

    # access current user with current_user
    puts current_user

    ##search for gameboard with open lobby
    unless gameboard = Gameboard.find_by(current_state: awaiting_players)
      gameboard = Gameboard.create(current_state: awaiting_players)
    end


    player = Player.new(gameboard_id: gameboard.id)

    player.save

    ##add user to player



    # puts gameboard
    # puts gameboard.players


    lobbyisfull = false


    if gameboard.players.count > 3 
        gameboard.current_state = "started"
        ### add who is allowed to play
        # gameboard.current_user = gameboard.players.first
        gameboard.save
        lobbyisfull = true
    end


    @gameboard = Gameboard.find(gameboard.id)
    stream_for @gameboard

    broadcast_to(@gameboard, "new Player conected to the gameboard id: #{@gameboard.id}")
    broadcast_to(@gameboard, "players in lobby: #{@gameboard.players.count}")

    # if lobby is full tell other players
    if lobbyisfull
      broadcast_to(@gameboard, "Lobby is full start with game")
      broadcast_to(@gameboard, {action:"init", gameboard:@gameboard.players})
    end

  end


  def play_card(data)
    ###add actions!
    puts data
    broadcast_to(@gameboard, {action:'player played',  data: data})
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end


  private

  def deliver_error_message(e)
    # broadcast_to(...)
  end

end
