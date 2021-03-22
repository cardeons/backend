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

  def flee
    output = Gameboard.flee(@gameboard)
    broadcast_to(@gameboard, { type: FLEE, params: output })
    name = current_user.name
    msg = if output[:flee] == true
            "Nice! #{name} rolled #{output[:value]}, #{name} managed to escape :)"
          else
            "Oh no! #{name} only rolled #{output[:value]}. That's a fine mess!"
          end

    log = { date: Time.new, message: msg }
    broadcast_to(@gameboard, { type: GAME_LOG, params: log })
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })
  end

  def play_monster(params)

    # move all centercard to graveyard
    centercard = Centercard.find_by('gameboard_id = ?', @gameboard.id)

    # centercard.ingamedecks.each do |ingamedeck|
    #   ingamedeck.update(cardable: Graveyard.find_by('gameboard_id = ?', @gameboard.id))
    # end

    centercard.ingamedeck.update(cardable: Graveyard.find_by('gameboard_id = ?', @gameboard.id))

    # update handcard to centercard
    Ingamedeck.find_by('id=?', params['unique_card_id']).update(cardable: Centercard.find_by('gameboard_id = ?', @gameboard.id))
    monsteratk = Ingamedeck.find_by('id=?', params['unique_card_id']).card.atk_points
    centercard = Centercard.find_by('gameboard_id = ?', @gameboard.id)

    @gameboard.update(centercard: centercard, monster_atk: monsteratk)

    result = Gameboard.attack(@gameboard)
    gameboard.update(success: result[:result], player_atk: result[:playeratk], monster_atk: result[:monsteratk])
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })
    name = @gameboard.centercard.card.title
    player = Player.find_by('user_id = ?', current_user.id)
    msg = "#{player.name} has played #{name} from handcards!"
    
    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })
  end

  def draw_door_card
    name = Gameboard.draw_door_card(@gameboard)
    # attack()
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
    msg = "#{current_user.player.name} has drawn #{name}"
    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
  end

  def equip_monster(params)
    player = Player.find_by('user_id = ?', current_user.id)

    result = Monstercard.equip_monster(params, player)

    updated_board = Gameboard.broadcast_game_board(@gameboard)

    broadcast_to(@gameboard, { type: 'ERROR', params: { message: result[:message] } }) if result[:type] == 'ERROR'
    broadcast_to(@gameboard, { type: 'BOARD_UPDATE', params: updated_board })

    if result[:type] != 'ERROR'
      msg = "#{player.name} has equiped a monster!"
      broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
    end
    
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })
  end

  def attack
    result = Gameboard.attack(@gameboard)
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })

    msg = "#{Player.find_by('gameboard_id = ?', @gameboard.id).name} has drawn #{name}"
    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
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
    player = Player.find_by('id=?', current_user.player.id)
    ingamedeck = Ingamedeck.find_by('id = ?', unique_card_id)

    case to
    when 'inventory'
      ingamedeck.update_attribute(:cardable, player.inventory)
    when 'player_monster'
      if ingamedeck.card.type != 'Monstercard'
        # ##make sure no items are placed in the monsterslot
        PlayerChannel.broadcast_to(current_user, { type: ERROR, params: { message: 'You can not equip an item without a monster' } })
      elsif player.monsterone.cards.count < 1
        ingamedeck.update(cardable: player.monsterone)
        msg = "#{player.name} has a new monster helping to defeat the enemy!"
        broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
      elsif player.monstertwo.cards.count < 1
        ingamedeck.update(cardable: player.monstertwo)
        msg = "#{player.name} has a new monster helping to defeat the enemy!"
        broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
      elsif player.monsterthree.cards.count < 1
        ingamedeck.update(cardable: player.monsterthree)
        msg = "#{player.name} has a new monster helping to defeat the enemy!"
        broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
      else
        broadcast_to(@gameboard, { type: DEBUG, params: { message: 'All monsterslots are full' } })
        PlayerChannel.broadcast_to(current_user, { type: ERROR, params: { message: 'All monsterslots are full!' } })
      end
    end

    monstercards1 = player.monsterone.cards.sum(:atk_points) if player.monsterone

    monstercards2 = player.monstertwo.cards.sum(:atk_points) if player.monstertwo

    monstercards3 = player.monsterthree.cards.sum(:atk_points) if player.monsterthree

    playeratkpoints = monstercards1 + monstercards2 + monstercards3 + player.level

    player.update_attribute(:attack, playeratkpoints)

    @gameboard.update_attribute(:player_atk, playeratkpoints)

    gameboard = Gameboard.find(@gameboard.id)
    
    # get updatet result of attack
    attack_obj = Gameboard.attack(gameboard)
    gameboard.update(success: attack_obj[:result], player_atk: attack_obj[:playeratk], monster_atk: attack_obj[:monsteratk])

    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })

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
