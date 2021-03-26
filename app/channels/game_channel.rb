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
    @gameboard.centercard.ingamedeck&.update!(cardable: @gameboard.graveyard)
    @gameboard.ingame!
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks.reload) } })
  end

  def play_monster(params)
    # move all centercard to graveyard
    centercard = Centercard.find_by('gameboard_id = ?', @gameboard.id)

    # centercard.ingamedecks.each do |ingamedeck|
    #   ingamedeck.update(cardable: Graveyard.find_by('gameboard_id = ?', @gameboard.id))
    # end

    centercard.ingamedeck&.update(cardable: Graveyard.find_by('gameboard_id = ?', @gameboard.id))

    # update handcard to centercard
    Ingamedeck.find_by('id=?', params['unique_card_id']).update(cardable: Centercard.find_by('gameboard_id = ?', @gameboard.id))
    monsteratk = Ingamedeck.find_by('id=?', params['unique_card_id']).card.atk_points
    centercard = Centercard.find_by('gameboard_id = ?', @gameboard.id)

    @gameboard.update(centercard: centercard, monster_atk: monsteratk)
    @gameboard.intercept_phase!
    @gameboard.players.each do |player|
      player.update!(intercept: true)
    end

    result = Gameboard.attack(@gameboard)
    @gameboard.update(success: result[:result], player_atk: result[:playeratk], monster_atk: result[:monsteratk])
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })
    name = @gameboard.centercard.card.title
    player = Player.find_by('user_id = ?', current_user.id)
    msg = "#{player.name} has played #{name} from handcards!"

    @gameboard.reload
    start_intercept_phase(@gameboard)

    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })
  end

  def draw_door_card
    name = Gameboard.draw_door_card(@gameboard)

    start_intercept_phase(@gameboard.reload)

    # attack()
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
    msg = "#{current_user.player.name} has drawn #{name}"
    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
  end

  def equip_monster(params)
    player = Player.find_by('user_id = ?', current_user.id)

    result = Monstercard.equip_monster(params, player)

    updated_board = Gameboard.broadcast_game_board(@gameboard)

    PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: result[:message] } }) if result[:type] == 'ERROR'
    broadcast_to(@gameboard, { type: 'BOARD_UPDATE', params: updated_board })

    if result[:type] != 'ERROR'
      msg = "#{player.name} has equiped a monster!"
      broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
    end

    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })
  end

  def attack
    result = Gameboard.attack(@gameboard)

    if result[:result]
      player = Player.find_by('user_id = ?', current_user.id)

      player_level = player.level
      player.update!(level: player_level + 1)

      if player.level == 5
        monster_id = player.win_game(current_user)
        @gameboard.game_won!
        broadcast_to(@gameboard, { type: 'WIN', params: { player: player.id, monster_won: monster_id } })
        return
      end

      rewards = @gameboard.rewards_treasure
      shared_reward = @gameboard.shared_reward
      current_player_treasure = rewards - shared_reward

      Handcard.draw_handcards(@gameboard.current_player, @gameboard, current_player_treasure)
      # TODO: add helping player to gameboard? give treasures to helping player
      if @gameboard.helping_player
        helping_player = @gameboard.helping_player
        Handcard.draw_handcards(helping_player, @gameboard, shared_reward)
      end
      @gameboard.centercard.ingamedeck&.update!(cardable: @gameboard.graveyard)
      msg = "#{current_user.player.name} has killed #{@gameboard.centercard.card.title}"
      broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })

      PlayerChannel.broadcast_to(current_user.reload, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })

      Gameboard.get_next_player(@gameboard)
      @gameboard.ingame!
      broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
    end

    PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: 'Playerattack too low' } }) unless result[:result]

    # updated_board = Gameboard.broadcast_game_board(@gameboard)
    # broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })

    # msg = "#{Player.find_by('gameboard_id = ?', @gameboard.id).name} has drawn #{name}"
    # broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
  end

  def intercept(params)
    # params={
    # action: "intercept",
    # unique_card_id: 1,
    # to: 'center_card' | 'current_player'
    # }

    unique_card_id = params['unique_card_id']
    to = params['to']

    # return if player does not own this card
    ingame_card = check_if_player_owns_card(unique_card_id) || return

    if ingame_card.card.type != 'Buffcard'
      # only buffcards are allowed alteast i think
      PlayerChannel.broadcast_error(current_user, 'This card cannot be used to intercept')
      return
    end

    current_user.player.reload
    @gameboard.reload

    case to
    when 'center_card'
      @gameboard.interceptcard.add_card_with_ingamedeck_id(unique_card_id)

    when 'current_player'
      # buff player
      @gameboard.playerinterceptcard.add_card_with_ingamedeck_id(unique_card_id)
    else
      PlayerChannel.broadcast_error(current_user, 'This is ont a correct field for to!')
      return
    end

    start_intercept_phase(@gameboard)

    # update this players handcards
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks.reload) } })
    # update board
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def no_interception
    current_user.reload
    current_user.player.update!(intercept: false)
    msg = "#{current_user.player.name} does not want to intercept this fight."
    @gameboard.reload

    if @gameboard.players.where('intercept = ?', false).count == 3
      msg = 'Nobody wants to intercept this turn.'
      @gameboard.intercept_finished!

      # #reset all player intercept values back to default (false)
      @gameboard.players.each do |player|
        player.update!(intercept: false)
      end

    end

    @gameboard.reload

    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def help_call(params)
    helping_player = Player.find_by('id = ?', params['helping_player_id'])
    helping_shared_reward = params['helping_shared_rewards']
    helping_player_id = helping_player.id
    @gameboard = @gameboard.reload

    unless current_user.player.id == @gameboard.current_player
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "It's not your round, you can't ask for help..." } })
      return
    end
    if @gameboard.asked_help
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: 'You already asked for help...' } })
      return
    end
    if helping_shared_reward > @gameboard.rewards_treasure
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "Can't share more rewards than monster gives" } })
      return
    end

    @gameboard.update(shared_reward: helping_shared_reward, asked_help: true, helping_player: helping_player_id)

    user_to_broadcast_to = User.where(player: helping_player).first

    unless helping_shared_reward > @gameboard.rewards_treasure

      PlayerChannel.broadcast_to(user_to_broadcast_to,
                                 { type: 'ASK_FOR_HELP',
                                   params: { player_id: helping_player_id, player_name: current_user.player.name, helping_shared_rewards: helping_shared_reward,
                                             helping_player_attack: helping_player.attack } })
    end
  end

  def answer_help_call(params)
    if params['help'] && @gameboard.helping_player
      helping_player_id = @gameboard.helping_player
      helping_player = Player.find_by('id = ?', helping_player_id)

      @gameboard.update(helping_player_atk: helping_player.attack)
    end

    @gameboard.update(shared_reward: 0) unless params['help']

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

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

    monstercards1 = Monstercard.calculate_monsterslot_atk(player.monsterone)
    monstercards2 = Monstercard.calculate_monsterslot_atk(player.monstertwo)
    monstercards3 = Monstercard.calculate_monsterslot_atk(player.monsterthree)

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

  def curse_player(params)
    player = Player.find_by('id=?', current_user.player.id)
    Cursecard.handlecurse(params, @gameboard, current_user)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def develop_add_buff_card
    card = Buffcard.all.first
    current_user.player.handcard.ingamedecks.create(card: card, gameboard: current_user.player.gameboard)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks) } })
  end

  def develop_add_curse_card
    card = Cursecard.all.last
    current_user.player.handcard.ingamedecks.create(card: card, gameboard: current_user.player.gameboard)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks) } })
  end

  def develop_add_card_with_id(params)
    card = Card.find_by('id=?', params['card_id'])
    current_user.player.handcard.ingamedecks.create(card: card, gameboard: current_user.player.gameboard)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks) } })
  end

  def develop_broadcast_handcard_update
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks) } })
  end

  def develop_broadcast_gameboard_update
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard.reload) })
  end

  def develop_set_myself_as_current_player
    current_user.player.gameboard.update!(current_player: current_user.player.id)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard.reload) })
  end

  def develop_set_intercept_false
    @gameboard.players.each do |player|
      player.reload.update!(intercept: false)
    end

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard.reload) })
  end

  def develop_set_myself_as_winner
    player = Player.find_by('user_id = ?', current_user.id)

    player.update!(level: 5)

    monster_id = player.win_game(current_user)
    @gameboard.game_won!
    broadcast_to(@gameboard, { type: 'WIN', params: { player: player.id, monster_won: monster_id } })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    # pp current_user.playerpp
    # pp current_user.player
    # id = current_user.player.reload.id
    # pp id
    # player = Player.find_by('id=?', id)

    # pp player

    # @gameboard.update!(current_player: 0) if @gameboard.current_player == id
    # pp "destroy player #{player}"

    # pp @gameboard
    # @gameboard.destroy!

    # @gameboard.destroy! if @gameboard.players.size < 1
    # player.destroy!

    # pp @gameboard.reload.players
  end

  private

  def deliver_error_message(_e)
    # broadcast_to(@gameboard, _e)
  end

  def check_if_player_owns_card(ingame_deck_id)
    card = current_user.player.handcard.ingamedecks.find_by('id=?', ingame_deck_id)
    # broadcast error to player channel if he does not own this ingamedeck_id
    if card
      # this method returns the card if player owns card
      card
    else
      PlayerChannel.broadcast_error(current_user, "You do not own this card #{ingame_deck_id}")
      # this method returns false if player does not own card
      false
    end
  end

  def start_intercept_phase(gameboard)
    gameboard.intercept_phase!

    timestamp = Time.now

    gameboard.update!(intercept_timestamp: timestamp)

    # sets Intercept Timer
    CheckIntercepttimerJob.set(wait: 40.seconds).perform_later(@gameboard, timestamp, 45)
  end
end
