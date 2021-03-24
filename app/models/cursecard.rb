# frozen_string_literal: true

class Cursecard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :type, presence: true

  def self.activate(ingamedeck, player, gameboard)
    case ingamedeck.card.action # get the action from card
    when 'lose_atk_points'
      player.update(attack: player.attack + ingamedeck.card.atk_points)
    when 'lose_item_hand'
      monster_arr = []
      monster_slot = []
      if player.monsterone.cards.where(item_category: 'hand').any?
        monster_arr.push(player.monsterone.cards.where(item_category: 'hand'))
        monster_slot.push(player.monsterone)
      end
      if player.monstertwo.cards.where(item_category: 'hand').any?
        monster_arr.push(player.monstertwo.cards.where(item_category: 'hand'))
        monster_slot.push(player.monstertwo)
      end
      if player.monsterthree.cards.where(item_category: 'hand').any?
        monster_arr.push(player.monsterthree.cards.where(item_category: 'hand'))
        monster_slot.push(player.monsterthree)
      end

      if monster_arr.length.positive?
        random = rand(0..monster_arr.length - 1)
        offset = rand(monster_arr[random].count)
        random_card_id = monster_arr[random].offset(offset).first.id

        Ingamedeck.where(card_id: random_card_id, cardable: monster_slot[random]).first&.update!(cardable: gameboard.graveyard)
      end
      ingamedeck.update(cardable: gameboard.graveyard)
    when 'no_help_next_fight'
      gameboard.update(asked_help: true)

      ingamedeck.update(cardable: gameboard.graveyard)
    when 'minus_atk_next_fight'
      gameboard.update(player_atk: gameboard.player_atk + ingamedeck.card.atk_points)

      ingamedeck.update(cardable: gameboard.graveyard)
    when 'lose_item_head'
      monster_arr = []
      monster_slot = []
      if player.monsterone.cards.where(item_category: 'head').any?
        monster_arr.push(player.monsterone.cards.where(item_category: 'head'))
        monster_slot.push(player.monsterone)
      end
      if player.monstertwo.cards.where(item_category: 'head').any?
        monster_arr.push(player.monstertwo.cards.where(item_category: 'head'))
        monster_slot.push(player.monstertwo)
      end
      if player.monsterthree.cards.where(item_category: 'head').any?
        monster_arr.push(player.monsterthree.cards.where(item_category: 'head'))
        monster_slot.push(player.monsterthree)
      end

      if monster_arr.length.positive?
        random = rand(0..monster_arr.length - 1)
        offset = rand(monster_arr[random].count)
        random_card_id = monster_arr[random].offset(offset).first.id

        Ingamedeck.where(card_id: random_card_id, cardable: monster_slot[random]).first&.update!(cardable: gameboard.graveyard)
      end
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
