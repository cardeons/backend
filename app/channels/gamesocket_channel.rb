# frozen_string_literal: true

class GamesocketChannel < ApplicationCable::Channel
  rescue_from Exception, with: :deliver_error_message

  def subscribed
    awaiting_players = 'awaiting_players'

    # access current user with current_user
    puts current_user

    # #search for gameboard with open lobby
    unless gameboard = Gameboard.find_by(current_state: awaiting_players)
      gameboard = Gameboard.create(current_state: awaiting_players)
    end

    player = Player.new(gameboard_id: gameboard.id)


    player.user = current_user
    player.save!

    # #add user to player

    # puts gameboard
    # puts gameboard.players

    lobbyisfull = false

    if gameboard.players.count > 3
      gameboard.current_state = 'started'
      ### add who is allowed to play
      # gameboard.current_user = gameboard.players.first
      gameboard.save
      lobbyisfull = true
    end

    @gameboard = Gameboard.find(gameboard.id)
    stream_for @gameboard

    broadcast_to(@gameboard, "new Player#{current_user.email} conected to the gameboard id: #{@gameboard.id}")
    broadcast_to(@gameboard, "players in lobby: #{@gameboard.players.count}")


   @gameboard.players.each do |player|
    PlayerChannel.broadcast_to( player.user , "only you should get this you are  #{player.user.email}" )
   end


    # if lobby is full tell other players
    if lobbyisfull

        players = @gameboard.players
        # much to do
        players.each do |player|
          handcard = Handcard.create(player_id: player.id)
          Ingamedeck.new(gameboard_id: @gameboard.id, card_id: 1, cardable_id: handcard.id, cardable_type: 'Handcard').save!
          Ingamedeck.new(gameboard_id: @gameboard.id, card_id: 2, cardable_id: handcard.id, cardable_type: 'Handcard').save!

          # player.handcard.cards << (Card.find(1))
          # player.handcard.cards << (Card.find(2))
          puts "--------------------"
          puts player.handcard.cards

          # broadcast_to(@gameboard, "player.handcard.cards")

          # broadcast_to(@gameboard, player.handcard.cards)
          
          PlayerChannel.broadcast_to(player.user, player.handcard.cards )
        end

      broadcast_to(@gameboard, 'Lobby is full start with game')
      broadcast_to(@gameboard, { action: 'startGame', gameboard: @gameboard.players })
    end
  end

  def play_card(data)
    # ##add actions!

    dataObject = JSON.parse data
    puts data



    
    broadcast_to(@gameboard, { action: 'player played', data: data })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def deliver_error_message(e)
    broadcast_to(...)
  end
end
