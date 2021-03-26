# frozen_string_literal: true

class Cursecard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :type, presence: true

  def self.handlecurse(params, gameboard, current_user)
    ingamedeck = Ingamedeck.find_by('id = ?', params['unique_card_id'])
    player_to = Player.find_by('id = ?', params['to'])

    Levelcard.activate(ingamedeck, player_to) if ingamedeck.card.type == 'Levelcard'

    unless ingamedeck.card.type == 'Cursecard'
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "You can't curse someone with a card that is not a cursecard..." } })
      return
    end

    ingamedeck.update(cardable: player_to.playercurse)
    activate(ingamedeck, player_to, gameboard) if ingamedeck.card.action == 'lose_item_head' || ingamedeck.card.action == 'lose_item_hand' || ingamedeck.card.action == 'lose_level'
  end

  def self.broadcast_gamelog(msg, gameboard)
    GameChannel.broadcast_to(gameboard, { type: 'GAME_LOG', params: { date: Time.new, message: msg } })
  end

  def self.activate(ingamedeck, player, gameboard, playeratk = 0, monsteratk = 0, gamelog = false)
    case ingamedeck.card.action # get the action from card
    when 'lose_atk_points'
      playeratk += ingamedeck.card.atk_points
      msg = "You lost #{ingamedeck.card.atk_points} because of Cursecard #{ingamedeck.card.title}"
      Cursecard.broadcast_gamelog(msg, gameboard) if gamelog

      { playeratk: playeratk, monsteratk: monsteratk }
    when 'lose_item_hand'
      Monstercard.lose_item_by_category(player, gameboard, 'hand')

      ingamedeck.update(cardable: gameboard.graveyard)
      msg = "You lost an Handitem because of Cursecard #{ingamedeck.card.title}"
      Cursecard.broadcast_gamelog(msg, gameboard) if gamelog

      { playeratk: playeratk, monsteratk: monsteratk }
    when 'no_help_next_fight'
      gameboard.update(asked_help: true)

      msg = "You can not ask for help because of Cursecard #{ingamedeck.card.title}"
      Cursecard.broadcast_gamelog(msg, gameboard) if gamelog

      { playeratk: playeratk, monsteratk: monsteratk }
    when 'minus_atk_next_fight'
      playeratk += ingamedeck.card.atk_points

      msg = "You lost #{ingamedeck.card.atk_points} because of Cursecard #{ingamedeck.card.title}"
      Cursecard.broadcast_gamelog(msg, gameboard) if gamelog

      { playeratk: playeratk, monsteratk: monsteratk }
    when 'lose_item_head'
      Monstercard.lose_item_by_category(player, gameboard, 'head')
      ingamedeck.update(cardable: gameboard.graveyard)

      msg = "You lost an Headitem because of Cursecard #{ingamedeck.card.title}"
      Cursecard.broadcast_gamelog(msg, gameboard) if gamelog

      { playeratk: playeratk, monsteratk: monsteratk }
    when 'lose_level'
      player.update(level: player.level - 1) unless player.level == 1

      ingamedeck.update(cardable: gameboard.graveyard)
      msg = "You lost a level because of Cursecard #{ingamedeck.card.title}"
      Cursecard.broadcast_gamelog(msg, gameboard) if gamelog

      { playeratk: playeratk, monsteratk: monsteratk }
    when 'double_attack_double_reward'

      pp 'am i in lmao??'
      pp monsteratk
      pp '******************************'
      pp '******************************'

      msg = "The monster has double the attack but also double the reward because of Cursecard #{ingamedeck.card.title}"
      Cursecard.broadcast_gamelog(msg, gameboard) if gamelog

      monstercard = gameboard.centercard.card

      monsteratk = monstercard.atk_points * 2 if monstercard
      pp 'updated monsteratk'
      pp monsteratk

      pp monstercard.rewards_treasure
      pp 'updated rewards'
      pp monstercard.rewards_treasure.to_i * 2
      gameboard.update(rewards_treasure: monstercard.rewards_treasure.to_i * 2, monster_atk: monsteratk) if monstercard
      { playeratk: playeratk, monsteratk: monsteratk }
    else
      puts 'action not found'
    end
  end
end
