# frozen_string_literal: true

class GameChannel < ApplicationCable::Channel
  rescue_from Exception, with: :deliver_error_message
  BOARD_UPDATE = "BOARD_UPDATE"  
  DEBUG = "DEBUG"
  ERROR = "ERROR"


  def subscribed
    @gameboard = current_user.player.gameboard
    stream_for @gameboard

    broadcast_to(@gameboard, {type: DEBUG ,params: { message:"you are now subscribed to the game_channel #{@gameboard.id}"}})

    broadcast_to(@gameboard, {type: BOARD_UPDATE, params: Gameboard.broadcast_gameBoard(@gameboard)})
    end
  end

  def play_card(params)
    #add actions!

    paramsObject = JSON.parse params
    puts paramsObject

    broadcast_to(@gameboard, {type: DEBUG ,params: { message:"You just used play_card with ", params: paramsObject}})
    

    case paramsObject.to
    when "Inventory"
      broadcast_to(@gameboard, {type: DEBUG ,params: { message:"Player #{current_user.email} just played to inventory"}})
      current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
      current_card.update_attribute(:cardable_type, "Inventory")
    when "Monsterone"
      broadcast_to(@gameboard, {type: DEBUG ,params: { message:"Player #{current_user.email} just played to monsterone"}})
      current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
      current_card.update_attribute(:cardable_type, "Monsterone")
    when "Monstertwo"
      broadcast_to(@gameboard, {type: DEBUG ,params: { message:"Player #{current_user.email} just played to monstertwo"}})
      current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
      current_card.update_attribute(:cardable_type, "Monstertwo")
    when "Monsterthree"
      broadcast_to(@gameboard, {type: DEBUG ,params: { message:"Player #{current_user.email} just played to monsterthree"}})
      current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
      current_card.update_attribute(:cardable_type, "Monsterthree")
    when "center"
      broadcast_to(@gameboard, {type: DEBUG ,params: { message:"Player #{current_user.email} just played to center"}})
      #TODO currently not implemented
    else
      broadcast_to(@gameboard, {type: ERROR ,params: { message:"Player #{current_user.email} just played to something i dont know"}})
    end
    
    broadcast_to(@gameboard, {type: BOARD_UPDATE, params: Gameboard.broadcast_gameBoard(@gameboard)})
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def deliver_error_message(e)
    broadcast_to(@gameboard)
  end
end
