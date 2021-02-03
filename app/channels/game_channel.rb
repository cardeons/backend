# frozen_string_literal: true

class GameChannel < ApplicationCable::Channel
  rescue_from Exception, with: :deliver_error_message
  BOARD_UPDATE = "BOARD_UPDATE"  
  DEBUG = "DEBUG"


  def subscribed


    @gameboard = current_user.player.gameboard

    stream_for @gameboard

    broadcast_to(@gameboard, {type: DEBUG ,params: { message:"you are now subscribed to the game_channel #{@gameboard.id}"}})

    broadcast_to(@gameboard, {type: BOARD_UPDATE, params:{@gameboard}})
    end
  end

  def play_card(data)
    #add actions!

    dataObject = JSON.parse data
    puts dataObject

    broadcast_to(@gameboard, {type: "DEBUG" ,params: { message:"You just used play_card with ", params: {dataObject}}})
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def deliver_error_message(e)
    broadcast_to(@gameboard)
  end
end
