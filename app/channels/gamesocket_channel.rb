class GamesocketChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  def subscribed

    awaiting_players = "awaiting_players"


    puts "inside subscribed gamesocket"


    # access current user with current_user
    puts current_user

    unless gameboard = Gameboard.find_by(current_state: awaiting_players)
      puts "inside unless"
      gameboard = Gameboard.create(current_state: awaiting_players)
    end


    player = Player.new(gameboard_id: gameboard.id)

    player.save

    ##add user to player



    # puts gameboard
    puts gameboard.players


    if gameboard.players.count == 4
        gameboard.current_state = "started"
        gameboard.current_user = gameboard.players.first
        gameboard.save
    end


    stream_from Gameboard.find(gameboard.id)

    stream_from Player.find(player.id)

    broadcast_to(gameboard, "you are now getting updates to your gameboard")

    broadcast_to(player, "you are now getting updates to your player")
    # stream_from 'gamesocket_channel_xxx'
    # for reference
    # stream_from "game_channel_#{params[:room]}"
    @gameboard = gameboard

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
