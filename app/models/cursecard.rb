# frozen_string_literal: true

class Cursecard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :type, presence: true

  def self.handlecurse(params, gameboard, current_user)
    ingamedeck = Ingamedeck.find_by('id = ?', params['unique_card_id'])
    player_to = Player.find_by('id = ?', params['to'])

    if ingamedeck.card.type == 'Levelcard'
      Levelcard.activate(ingamedeck, player_to)
    end

    unless ingamedeck.card.type == 'Cursecard'
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "You can't curse someone with a card that is not a cursecard..." } })
      return
    end

    ingamedeck.update(cardable: player_to.playercurse)
    activate(ingamedeck, player_to, gameboard) if ingamedeck.card.action == 'lose_item_head' || ingamedeck.card.action == 'lose_item_hand' || ingamedeck.card.action == 'lose_level'
  end

  def self.activate(ingamedeck, player, gameboard)
    case ingamedeck.card.action # get the action from card
    when 'lose_atk_points'
      player.update(attack: player.attack + ingamedeck.card.atk_points)
    when 'lose_item_hand'
      Monstercard.lose_item_by_category(player, gameboard, 'hand')

      ingamedeck.update(cardable: gameboard.graveyard)
    when 'no_help_next_fight'
      gameboard.update(asked_help: true)

      ingamedeck.update(cardable: gameboard.graveyard)
    when 'minus_atk_next_fight'
      gameboard.update(player_atk: gameboard.player_atk + ingamedeck.card.atk_points)

      ingamedeck.update(cardable: gameboard.graveyard)
    when 'lose_item_head'
      Monstercard.lose_item_by_category(player, gameboard, 'head')
      ingamedeck.update(cardable: gameboard.graveyard)
    when 'lose_level'
      player.update(level: player.level - 1) unless player.level == 1

      ingamedeck.update(cardable: gameboard.graveyard)
    when 'double_attack_double_reward'
      gameboard.update(player_atk: gameboard.player_atk * 2, rewards_treasure: gameboard.rewards_treasure + 2)

      ingamedeck.update(cardable: gameboard.graveyard)
    else
      puts 'action not found'
    end
  end
end
