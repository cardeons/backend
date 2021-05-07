# frozen_string_literal: true

class GameChannel < ApplicationCable::Channel
  # rescue_from Exception, with: :deliver_error_message
  BOARD_UPDATE = 'BOARD_UPDATE'
  DEBUG = 'DEBUG'
  ERROR = 'ERROR'
  FLEE = 'FLEE'
  GAME_LOG = 'GAME_LOG'

  def subscribed
    current_user.ingame!
    @gameboard = current_user.player.gameboard
    current_user.player.update!(inactive: false)
    stream_for @gameboard

    broadcast_to(@gameboard, { type: DEBUG, params: { message: "you are now subscribed to the game_channel #{@gameboard.id}" } })

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def flee
    return unless validate_user

    output = Gameboard.flee(@gameboard, current_user)
    broadcast_to(@gameboard, { type: FLEE, params: output })

    @gameboard.centercard.ingamedeck&.update!(cardable: @gameboard.graveyard)
    @gameboard.ingame!
    updated_board = Gameboard.broadcast_game_board(@gameboard)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks.reload) } })
  end

  def play_monster(params)
    # move all centercard to graveyard
    if @gameboard.reload.current_player != current_user.player
      PlayerChannel.broadcast_error(current_user, 'Only the the Player whos turn it is can play a Monster')
      return
    end

    unique_card_id = params['unique_card_id']

    ingame_card = check_if_player_owns_card(unique_card_id) || return

    if ingame_card.card.type != 'Monstercard'
      # only buffcards are allowed alteast i think
      PlayerChannel.broadcast_error(current_user, "You can't fight against this card!")
      return
    end

    centercard = Centercard.find_by('gameboard_id = ?', @gameboard.id)

    centercard.ingamedeck&.update(cardable: Graveyard.find_by('gameboard_id = ?', @gameboard.id))

    # update handcard to centercard
    ingame_card.update(cardable: Centercard.find_by('gameboard_id = ?', @gameboard.id))

    @gameboard.intercept_phase!
    @gameboard.players.each do |player|
      player.update!(intercept: true)
    end

    @gameboard.update_recalc_element_synergy_modifer

    updated_board = Gameboard.broadcast_game_board(@gameboard.reload)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })

    name = @gameboard.centercard.card.title
    player = Player.find_by('user_id = ?', current_user.id)

    msg = "👀 #{player.name} has played #{name} from their handcards!"

    @gameboard.reload
    start_intercept_phase(@gameboard)

    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg, type: 'info' } })
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })
  end

  def draw_door_card
    @gameboard.reload
    # if intercept phase is already active player should not be able to draw another card
    if @gameboard.intercept_phase? || @gameboard.intercept_finished?
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "You can't draw another card!" } })
      return
    end

    name = Gameboard.draw_door_card(@gameboard)

    @gameboard.reload.update_recalc_element_synergy_modifer
    start_intercept_phase(@gameboard.reload)

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard.reload) })
    msg = "👀 #{current_user.player.name} has drawn #{name}"
    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg, type: 'info' } })
  end

  def equip_monster(params)
    player = Player.find_by('user_id = ?', current_user.id)

    result = Monstercard.equip_monster(params, player)

    updated_board = Gameboard.broadcast_game_board(@gameboard)

    PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: result[:message] } }) if result[:type] == 'ERROR'
    broadcast_to(@gameboard, { type: 'BOARD_UPDATE', params: updated_board })

    # if result[:type] != 'ERROR'
    #   msg = "#{player.name} has equiped a monster!"
    #   broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
    # end

    if @gameboard.current_player == player
      @gameboard.update_recalc_element_synergy_modifer
      broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard.reload) })
    end

    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })
  end

  def attack
    return unless validate_user

    result = Gameboard.calc_attack_points(@gameboard.reload)

    if result[:result]

      rewards = @gameboard.rewards_treasure

      # boss monster, no levels, just rewards
      # if @gameboard.boss_phase?
      #   @gameboard.players.each do |player|
      #     Handcard.draw_handcards(player.id, @gameboard, rewards)
      #     PlayerChannel.broadcast_to(player.user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.reload.ingamedecks) } })
      #   end
      #   msg = "⚔ You all killed #{@gameboard.centercard.card.title}!"
      # # normal monster
      # else
      player = current_user.player
      player_level = player.level
      player.update!(level: player_level + @gameboard.reload.centercard.card.level_amount)

      if player.level >= 5
        monster_id = player.win_game(current_user)
        @gameboard.game_won!
        broadcast_to(@gameboard, { type: 'WIN', params: { player: player.id, monster_won: monster_id } })
        broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
        return
      end

      shared_reward = @gameboard.shared_reward
      current_player_treasure = rewards - shared_reward
      Handcard.draw_handcards(@gameboard.current_player.id, @gameboard, current_player_treasure)
      PlayerChannel.broadcast_to(current_user.reload, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.reload.ingamedecks) } })

      if @gameboard.reload.helping_player
        helping_player = @gameboard.helping_player
        Handcard.draw_handcards(helping_player.id, @gameboard, shared_reward)

        PlayerChannel.broadcast_to(helping_player.user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(helping_player.handcard.reload.ingamedecks) } })
        msg = "⚔ #{current_user.player.name} has killed #{@gameboard.centercard.card.title}"
      end
      # end

      broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg, type: 'success' } })
      @gameboard.centercard.ingamedeck&.update!(cardable: @gameboard.graveyard)

      Gameboard.get_next_player(@gameboard)
      @gameboard.ingame!
      broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
    end

    Gameboard.clear_buffcards(@gameboard)
    PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: '❌ Attack too low' } }) unless result[:result]

    # updated_board = Gameboard.broadcast_game_board(@gameboard)
    # broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })

    # msg = "#{Player.find_by('gameboard_id = ?', @gameboard.id).name} has drawn #{name}"
    # broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg } })
  end

  def intercept(params)
    @gameboard.reload

    if @gameboard.centercard.nil?
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "❌ There's no card in the center!" } })
      return
    end

    # intercept shouldn't be possible if it's not the right phase
    return PlayerChannel.broadcast_error(current_user, "❌ You can't intercept right now, it's #{@gameboard.current_state} phase") if !@gameboard.intercept_phase? && !@gameboard.boss_phase?

    # if @gameboard.intercept_phase? || @gameboard.boss_phase?
    unique_card_id = params['unique_card_id']
    to = params['to']

    # return if player does not own this card
    ingame_card = check_if_player_owns_card(unique_card_id) || return

    if ingame_card.card.type != 'Buffcard'
      # only buffcards are allowed alteast i think
      PlayerChannel.broadcast_error(current_user, '❌ This card cannot be used to intercept')
      return
    end

    current_user.player.reload

    case to
    when 'center_card'
      @gameboard.interceptcard.add_card_with_ingamedeck_id(unique_card_id)
      msg = "💪 #{current_user.player.name} buffed the monster!"
      Buffcard.broadcast_gamelog(msg, @gameboard)
    when 'current_player'
      # buff player
      @gameboard.playerinterceptcard.add_card_with_ingamedeck_id(unique_card_id)
      msg = "💪 #{current_user.player.name} buffed #{@gameboard.current_player.name}."
      Buffcard.broadcast_gamelog(msg, @gameboard)
    else
      PlayerChannel.broadcast_error(current_user, '❌ This is not a correct field to play your card!')
      return
    end

    start_intercept_phase(@gameboard) unless @gameboard.boss_phase?

    # update this players handcards
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks.reload) } })
    # update board
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def no_interception
    current_user.reload
    current_user.player.update!(intercept: false)
    msg = "❌ #{current_user.player.name} does not want to intercept this fight."
    @gameboard.reload

    if @gameboard.players.where('intercept = ?', false).count == 3
      msg = '📢 Nobody wants to intercept this turn.'
      @gameboard.intercept_finished!

      # #reset all player intercept values back to default (false)
      @gameboard.players.each do |player|
        player.update!(intercept: false)
      end

    end

    @gameboard.reload

    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg, type: 'info' } })
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def help_call(params)
    helping_player = Player.find_by('id = ?', params['helping_player_id'])
    helping_shared_reward = params['helping_shared_rewards']
    helping_player_id = helping_player.id
    @gameboard = @gameboard.reload

    return unless validate_user

    # no help call in bossphase
    if @gameboard.boss_phase?
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "❌ You're in this together! No need to ask for help during a bossfight." } })
      return
    end

    if @gameboard.asked_help
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: '❌ You already asked for help...' } })
      return
    end
    if helping_shared_reward > @gameboard.rewards_treasure
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "❌ Can't share more rewards than monster gives" } })
      return
    end

    msg = "👀 You asked #{helping_player.name} for help in this fight. Lets see.."
    PlayerChannel.broadcast_to(current_user, { type: 'GAME_LOG', params: { date: Time.new, message: msg, type: 'info' } })

    @gameboard.update(shared_reward: helping_shared_reward, asked_help: true, helping_player: helping_player)

    user_to_broadcast_to = User.where(player: helping_player).first

    PlayerChannel.broadcast_to(user_to_broadcast_to,
                               { type: 'ASK_FOR_HELP',
                                 params: { player_id: helping_player_id, player_name: current_user.player.name, helping_shared_rewards: helping_shared_reward,
                                           helping_player_attack: helping_player.attack } })
  end

  def answer_help_call(params)
    # no help calls in bossphase
    return if @gameboard.boss_phase?

    if params['help'] && @gameboard.reload.helping_player
      helping_player = @gameboard.helping_player

      if @gameboard.monster_atk < (@gameboard.player_atk + helping_player.attack)
        @gameboard.update(success: true, helping_player_atk: helping_player.attack)
      else
        @gameboard.update(helping_player_atk: helping_player.attack)
      end
      msg = "✅ #{@gameboard.current_player.name} asked #{helping_player.name} for help in this fight. He agreed!"
      broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg, type: 'success' } })
      start_intercept_phase(@gameboard)
    end

    @gameboard.update(shared_reward: 0) unless params['help']
    msg = "❌ #{@gameboard.current_player.name} asked #{helping_player.name} for help in this fight. #{helping_player.name} declined!"
    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg, type: 'error' } }) unless params['help']

    @gameboard.reload

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def move_card(params)
    unique_card_id = params['unique_card_id']
    to = params['to']
    player = current_user.player.reload
    ingamedeck = Ingamedeck.find_by('id = ?', unique_card_id)

    case to
    when 'inventory'
      ingamedeck.update_attribute(:cardable, player.inventory)
    when 'player_monster'
      if ingamedeck.card.type != 'Monstercard'
        # make sure no items are placed in the monsterslot
        PlayerChannel.broadcast_to(current_user, { type: ERROR, params: { message: '❌ You can not equip an item without a monster' } })
      elsif player.monsterone.cards.count < 1
        ingamedeck.update(cardable: player.monsterone)
        msg = "💪 #{player.name} has a new monster helping to defeat the enemy!"
        broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg, type: 'info' } })
      elsif player.monstertwo.cards.count < 1
        ingamedeck.update(cardable: player.monstertwo)
        msg = "💪 #{player.name} has a new monster helping to defeat the enemy!"
        broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg, type: 'info' } })
      elsif player.monsterthree.cards.count < 1
        ingamedeck.update(cardable: player.monsterthree)
        msg = "💪 #{player.name} has a new monster helping to defeat the enemy!"
        broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg, type: 'info' } })
      else
        broadcast_to(@gameboard, { type: DEBUG, params: { message: 'All monsterslots are full' } })
        PlayerChannel.broadcast_to(current_user, { type: ERROR, params: { message: '❌ All monsterslots are full!' } })
      end
    end

    # recalc player atk
    playeratkpoints = player.calculate_player_atk_with_monster_and_items

    @gameboard.update_attribute(:player_atk, playeratkpoints)

    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def curse_player(params)
    ingame_card = check_if_player_owns_card(params['unique_card_id']) || return
    Cursecard.handlecurse(params, @gameboard, current_user)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks) } })
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def level_up(params)
    ingame_card = check_if_player_owns_card(params['unique_card_id']) || return

    Levelcard.activate(params, current_user)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks) } })
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def validate_user
    if current_user.player != @gameboard.current_player
      PlayerChannel.broadcast_error(current_user, "❌ You can't do that, it's not your turn...")
      return false
    end
    true
  end

  def develop_add_buff_card
    return unless developer_actions_enabled?

    card = Buffcard.all.first
    current_user.player.handcard.ingamedecks.create(card: card, gameboard: current_user.player.gameboard)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks) } })
  end

  def develop_add_curse_card
    return unless developer_actions_enabled?

    card = Cursecard.all.last
    current_user.player.handcard.ingamedecks.create(card: card, gameboard: current_user.player.gameboard)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks) } })
  end

  def develop_add_card_with_id(params)
    return unless developer_actions_enabled?

    card = Card.find_by('id=?', params['card_id'])
    current_user.player.handcard.ingamedecks.create(card: card, gameboard: current_user.player.gameboard)
    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks) } })
  end

  def develop_broadcast_handcard_update
    return unless developer_actions_enabled?

    PlayerChannel.broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(current_user.player.handcard.ingamedecks) } })
  end

  def develop_broadcast_gameboard_update
    return unless developer_actions_enabled?

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard.reload) })
  end

  def develop_set_myself_as_current_player
    return unless developer_actions_enabled?

    current_user.player.gameboard.update!(current_player: current_user.player)
    @gameboard.update_recalc_element_synergy_modifer
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard.reload) })
  end

  def develop_set_intercept_false
    return unless developer_actions_enabled?

    @gameboard.players.each do |player|
      player.reload.update!(intercept: false)
    end

    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard.reload) })
  end

  def develop_set_myself_as_winner
    return unless developer_actions_enabled?

    player = Player.find_by('user_id = ?', current_user.id)

    player.update!(level: 5)

    monster_id = player.win_game(current_user)
    @gameboard.game_won!
    broadcast_to(@gameboard, { type: 'WIN', params: { player: player.id, monster_won: monster_id } })
  end

  def develop_draw_boss_card
    return unless developer_actions_enabled?

    ## remove old centercard if neccessary
    unless @gameboard.centercard.nil?
      centercard = Centercard.find_by!('gameboard_id = ?', @gameboard.id)
      centercard.ingamedeck&.update!(cardable: @gameboard.graveyard)
    end

    # centercard
    card = Bosscard.all.first
    Ingamedeck.create(gameboard: @gameboard, card_id: card.id, cardable: centercard)

    new_center = Centercard.find_by('gameboard_id = ?', @gameboard.id)
    @gameboard.update(centercard: new_center)

    @gameboard.boss_phase!

    updated_board = Gameboard.broadcast_game_board(@gameboard.reload)

    start_intercept_phase(@gameboard.reload)
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: updated_board })
    msg = "👀 #{current_user.player.name} has drawn #{card.title}"
    broadcast_to(@gameboard, { type: GAME_LOG, params: { date: Time.new, message: msg, type: 'info' } })
  end

  def develop_set_next_player_as_current_player
    return unless developer_actions_enabled?

    Gameboard.get_next_player(@gameboard)
    @gameboard.update_recalc_element_synergy_modifer
    @gameboard.ingame!
    broadcast_to(@gameboard, { type: BOARD_UPDATE, params: Gameboard.broadcast_game_board(@gameboard) })
  end

  def send_chat_message(params)
    msg = params['message']

    broadcast_to(@gameboard, { type: 'CHAT_MESSAGE', params: { date: Time.new, id: current_user.player.id, name: current_user.player.name, message: msg } })
  end

  def unsubscribed
    current_user.reload.online!
    current_user.player.update!(inactive: true)

    @gameboard.destroy! if @gameboard.players.where(inactive: true).size > 3

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

    # player.destroy!

    # pp @gameboard.reload.players
  end

  private

  def deliver_error_message(_e)
    # broadcast_to(@gameboard, _e)
  end

  def developer_actions_enabled?
    # returns true if ENV['DEV_TOOL_ENABLED'] is set
    return true if ENV['DEV_TOOL_ENABLED'] == 'enabled'

    PlayerChannel.broadcast_error(current_user, "⛔ You can't use developer actions in this Environment")
    false
  end

  def check_if_player_owns_card(ingame_deck_id)
    card = current_user.player.handcard.ingamedecks.find_by('id=?', ingame_deck_id)
    # broadcast error to player channel if he does not own this ingamedeck_id
    if card
      # this method returns the card if player owns card
      card
    else
      PlayerChannel.broadcast_error(current_user, "❌ You do not own this card #{ingame_deck_id}")
      # this method returns false if player does not own card
      false
    end
  end

  def start_intercept_phase(gameboard)
    # if no boss monster has been drawn, state should be intercept_phase
    gameboard.intercept_phase! unless gameboard.boss_phase?

    gameboard.players.each do |player|
      player.update!(intercept: true)
    end

    timestamp = Time.now

    gameboard.update!(intercept_timestamp: timestamp)

    # sets Intercept Timer
    CheckIntercepttimerJob.set(wait: 40.seconds).perform_later(@gameboard, timestamp, 45)
  end
end
