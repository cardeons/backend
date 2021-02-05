# frozen_string_literal: true

class GameChannel < ApplicationCable::Channel
  # rescue_from Exception, with: :deliver_error_message
  BOARD_UPDATE = 'BOARD_UPDATE'
  DEBUG = 'DEBUG'
  ERROR = 'ERROR'
  FLEE = 'FLEE'
  GAME_LOG = 'GAME_LOG'

  def subscribed
    @gameboard = current_user.player.gameboard
    stream_for @gameboard

    broadcast_to(@gameboard, { type: DEBUG, params: { message: "you are now subscribed to the game_channel #{@gameboard.id}" } })

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def flee()
    output = Gameboard.flee(@gameboard);
    broadcast_to(@gameboard, {type: FLEE, params: output})
    msg=""
    name = current_user.name
    if output["flee"] = true
      msg = "Nice! #{name} rolled #{output["value"]}, #{name} managed to escape :)"
    else
      msg = "Oh no! #{name} only rolled #{output["value"]}. That's a fine mess!"
    end

    log = {date: Time.new, message: msg}
    broadcast_to(@gameboard, {type: GAME_LOG, params: log})
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })
  end

  def play_monster(params)
    centercard = Centercard.find_by('gameboard_id = ?', @gameboard.id)

    centercard.ingamedecks.each do |ingamedeck|
      ingamedeck.update(cardable: Graveyard.find_by('gameboard_id = ?', @gameboard.id))
    end

    Ingamedeck.find_by("id=?", params["unique_card_id"]).update(cardable: Centercard.find_by('gameboard_id = ?', @gameboard.id))
    monsteratk = Ingamedeck.find_by("id=?", params["unique_card_id"]).card.atk_points

    @gameboard.update(centercard: Centercard.find_by('gameboard_id = ?', @gameboard.id), monster_atk: monsteratk)

    result = Gameboard.attack(@gameboard)
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })  
    player = Player.find_by('user_id = ?', current_user.id)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.renderCardId(player.handcard.ingamedecks) } })
  end

  def draw_door_card()
    name = Gameboard.draw_door_card(@gameboard);
    # attack()
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
    msg = "#{Player.find_by("gameboard_id = ?",@gameboard.id).name} has drawn #{name}"
    broadcast_to(@gameboard, {type: GAME_LOG, params: {date: Time.new, message: msg}})
  end

  def equip_monster(params)
    player = Player.find_by('user_id = ?', current_user.id)
    result = Monstercard.equip_monster(params, player)

    updated_board = Gameboard.broadcast_game_board(@gameboard)

    if result[:type] == "ERROR"
    broadcast_to(@gameboard, { type: 'ERROR', params: { message: result[:message] }})
    end

    broadcast_to(@gameboard, { type: 'BOARD_UPDATE', params: updated_board  })
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.renderCardId(player.handcard.ingamedecks) } })

  end

  def attack()
    result = Gameboard.attack(@gameboard)
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })  
  end

  # def play_card(params)
  #   # add actions!

  #   paramsObject = JSON.parse params
  #   puts paramsObject

  #   broadcast_to(@gameboard, { type: DEBUG, params: { message: 'You just used play_card with ', params: paramsObject } })

  #   case paramsObject.to
  #   when 'Inventory'
  #     broadcast_to(@gameboard, { type: DEBUG, params: { message: "Player #{current_user.email} just played to inventory" } })
  #     current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
  #     current_card.update_attribute(:cardable_type, 'Inventory')
  #   when 'Monsterone'
  #     broadcast_to(@gameboard, { type: DEBUG, params: { message: "Player #{current_user.email} just played to monsterone" } })
  #     current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
  #     current_card.update_attribute(:cardable_type, 'Monsterone')
  #   when 'Monstertwo'
  #     broadcast_to(@gameboard, { type: DEBUG, params: { message: "Player #{current_user.email} just played to monstertwo" } })
  #     current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
  #     current_card.update_attribute(:cardable_type, 'Monstertwo')
  #   when 'Monsterthree'
  #     broadcast_to(@gameboard, { type: DEBUG, params: { message: "Player #{current_user.email} just played to monsterthree" } })
  #     current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
  #     current_card.update_attribute(:cardable_type, 'Monsterthree')
  #   when 'center'
  #     broadcast_to(@gameboard, { type: DEBUG, params: { message: "Player #{current_user.email} just played to center" } })
  #     # TODO: currently not implemented
  #   else
  #     broadcast_to(@gameboard, { type: ERROR, params: { message: "Player #{current_user.email} just played to something i dont know" } })
  #   end

  #   broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  # end

  def move_card(params)
    unique_card_id = params['unique_card_id']
    to = params['to']
    player = Player.find_by("id=?",current_user.player.id)

    case to
    when 'inventory'
      Ingamedeck.find_by("id = ?", unique_card_id).update_attribute(:cardable, player.inventory)
    when 'player_monster'
      if Ingamedeck.find_by("id=?",unique_card_id).card.type != "Monstercard"
        ###make sure no items are placed in the monsterslot
        PlayerChannel.broadcast_to(current_user,  { type: ERROR, params: { message: "You can not equip an item without a monster" } })
      elsif player.monsterone.cards.count < 1
        Ingamedeck.find_by("id = ?", unique_card_id).update(cardable: player.monsterone)
      elsif player.monstertwo.cards.count < 1
        Ingamedeck.find_by("id = ?", unique_card_id).update(cardable: player.monstertwo)
      elsif player.monsterthree.cards.count < 1
        Ingamedeck.find_by("id = ?", unique_card_id).update(cardable: player.monsterthree)
      else
        broadcast_to(@gameboard, { type: DEBUG, params: { message: "All monsterslots are full" } })
        PlayerChannel.broadcast_to(current_user,  { type: ERROR, params: { message: "All monsterslots are full!" } })
      end
    end

      if player.monsterone
      monstercards1 = player.monsterone.cards.sum(:atk_points)
      end
  
      if player.monstertwo
      monstercards2 = player.monstertwo.cards.sum(:atk_points)
      end
  
      if player.monsterthree
      monstercards3 = player.monsterthree.cards.sum(:atk_points)
      end
  
    playeratkpoints = monstercards1 + monstercards2 + monstercards3 + player.level


    @gameboard.update_attribute(:player_atk, playeratkpoints)

    gameboard = Gameboard.find(@gameboard.id)


    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.renderCardId(player.handcard.ingamedecks) } })

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(gameboard) })

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def deliver_error_message(_e)
    # broadcast_to(@gameboard, _e)
  end
end
