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
    @gameboard.update(centercard: Centercard.find_by('gameboard_id = ?', @gameboard.id))
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })  
    player = Player.find_by('user_id = ?', current_user.id)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.renderCardId(player.handcard.ingamedecks) } })
  end

  def draw_door_card()
    name = Gameboard.draw_door_card(@gameboard);
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
    msg = "#{Player.find_by("gameboard_id = ?",@gameboard.id).name} has drawn #{name}"
    broadcast_to(@gameboard, {type: GAME_LOG, params: {date: Time.new, message: msg}})
  end

  def equip_monster(params)
    # pp params
    player = Player.find_by('user_id = ?', current_user.id)
    result = Monstercard.equip_monster(params, player)
    pp result[:type]

    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: result[:type], message: result[:message], params: updated_board  })

    pp player.monsterone.ingamedecks
    pp player
    # pp player.monstertwo.ingamedecks
    # pp player.monsterthree.ingamedecks

  end

  def attack()
    result = Gameboard.attack(@gameboard)
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })  
  end

  def play_card(params)
    # add actions!

    paramsObject = JSON.parse params
    puts paramsObject

    broadcast_to(@gameboard, { type: DEBUG, params: { message: 'You just used play_card with ', params: paramsObject } })

    case paramsObject.to
    when 'Inventory'
      broadcast_to(@gameboard, { type: DEBUG, params: { message: "Player #{current_user.email} just played to inventory" } })
      current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
      current_card.update_attribute(:cardable_type, 'Inventory')
    when 'Monsterone'
      broadcast_to(@gameboard, { type: DEBUG, params: { message: "Player #{current_user.email} just played to monsterone" } })
      current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
      current_card.update_attribute(:cardable_type, 'Monsterone')
    when 'Monstertwo'
      broadcast_to(@gameboard, { type: DEBUG, params: { message: "Player #{current_user.email} just played to monstertwo" } })
      current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
      current_card.update_attribute(:cardable_type, 'Monstertwo')
    when 'Monsterthree'
      broadcast_to(@gameboard, { type: DEBUG, params: { message: "Player #{current_user.email} just played to monsterthree" } })
      current_card = Ingamedeck.find_by('id=?', paramsObject.unique_id)
      current_card.update_attribute(:cardable_type, 'Monsterthree')
    when 'center'
      broadcast_to(@gameboard, { type: DEBUG, params: { message: "Player #{current_user.email} just played to center" } })
      # TODO: currently not implemented
    else
      broadcast_to(@gameboard, { type: ERROR, params: { message: "Player #{current_user.email} just played to something i dont know" } })
    end

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def move_card(params)
    unique_card_id = params['unique_card_id']
    to = params['to']
    player = Player.find_by("id=?",current_user.player.id)
    pp "######______#############################"
    pp unique_card_id
    pp to

    case to
    when 'inventory'
      Ingamedeck.find_by("id = ?", unique_card_id).update_attribute(:cardable, player.inventory)
    when 'player_monster'
      if player.monsterone.cards.count < 1
        Ingamedeck.find_by("id = ?", unique_card_id).update(cardable: player.monsterone)
      elsif player.monstertwo.cards.count < 1
        Ingamedeck.find_by("id = ?", unique_card_id).update(cardable: player.monstertwo)
      elsif player.monsterthree.cards.count < 1
        Ingamedeck.find_by("id = ?", unique_card_id).update(cardable: player.monsterthree)
      else
        broadcast_to(@gameboard, { type: DEBUG, params: { message: "All monsterslots are full" } })
        PlayerChanel.broadcast_to(player,  { type: ERROR, params: { message: "All monsterslots are full!" } })
      end
    end

    pp "######______#########################313213213213213213133213213213132####"



    gameboard = Gameboard.find(@gameboard.id)

    pp player.monsterone.ingamedecks
    pp player
    pp "jkjkjkfsdfuuuioiu88888WWWWWWWWWWWWWWWW"
    pp player.inventory.ingamedecks
    pp player.handcard.cards
    pp player.handcard.ingamedecks



    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.renderCardId(player.handcard.ingamedecks) } })
    pp "######______############################222222222222222222222222222#"

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(gameboard) })

    pp player.monsterone.ingamedecks
    pp player.monsterone.ingamedecks
    pp player.monsterone.ingamedecks

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def deliver_error_message(_e)
    # broadcast_to(@gameboard, _e)
  end
end
