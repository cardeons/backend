# frozen_string_literal: true

class Cursecard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :type, presence: true

  def self.handlecurse(params, gameboard, current_user)
    ingamedeck = Ingamedeck.find_by('id = ?', params['unique_card_id'])
    player_to = Player.find_by('id = ?', params['to'])

    Levelcard.activate(ingamedeck, player_to) if ingamedeck.card.type == 'Levelcard'

    unless ingamedeck.card.type == 'Cursecard'
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "❌ You can't curse someone with a card that is not a cursecard..." } })
      return
    end

    ingamedeck.update(cardable: player_to.playercurse)
    if ingamedeck.card.action == 'lose_item_head' || ingamedeck.card.action == 'lose_item_hand' || ingamedeck.card.action == 'lose_level'
      activate(ingamedeck, player_to, gameboard)
    else
      msg = "🔮 #{player_to.name} got cursed! The curse will affect the player in the next fight."
      Cursecard.broadcast_gamelog(msg, gameboard)
    end
  end

  def self.broadcast_gamelog(msg, gameboard)
    GameChannel.broadcast_to(gameboard, { type: 'GAME_LOG', params: { date: Time.new, message: msg, type: 'dark' } })
  end

  def self.activate(ingamedeck, player, gameboard, playeratk = 0, monsteratk = 0)
    case ingamedeck.card.action # get the action from card
    when 'lose_atk_points'
      playeratk += ingamedeck.card.atk_points
      { playeratk: playeratk, monsteratk: monsteratk }
    when 'lose_item_hand'
      Monstercard.lose_item_by_category(player, gameboard, 'hand')

      ingamedeck.update(cardable: gameboard.graveyard)
      msg = "🔮 #{player.name} got cursed! The player lost a hand item because of it."
      Cursecard.broadcast_gamelog(msg, gameboard)

      { playeratk: playeratk, monsteratk: monsteratk }
    when 'no_help_next_fight'
      gameboard.update(asked_help: true)
      { playeratk: playeratk, monsteratk: monsteratk }
    when 'minus_atk_next_fight'
      playeratk += ingamedeck.card.atk_points

      { playeratk: playeratk, monsteratk: monsteratk }
    when 'lose_item_head'
      Monstercard.lose_item_by_category(player, gameboard, 'head')
      ingamedeck.update(cardable: gameboard.graveyard)

      msg = "🔮 #{player.name} got cursed! The player lost a head item because of it."
      Cursecard.broadcast_gamelog(msg, gameboard)

      { playeratk: playeratk, monsteratk: monsteratk }
    when 'lose_level'
      player.update(level: player.level - 1) unless player.level == 1

      ingamedeck.update(cardable: gameboard.graveyard)
      msg = "🔮 #{player.name} got cursed! The player lost a level because of it."
      Cursecard.broadcast_gamelog(msg, gameboard)

      { playeratk: playeratk, monsteratk: monsteratk }
    when 'double_attack_double_reward'
      monstercard = gameboard.centercard.card

      monsteratk = monstercard.atk_points * 2 if monstercard

      gameboard.update(rewards_treasure: monstercard.rewards_treasure.to_i * 2, monster_atk: monsteratk) if monstercard
      { playeratk: playeratk, monsteratk: monsteratk }
    else
      puts 'action not found'
    end
  end
end
