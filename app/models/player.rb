# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :gameboard
  has_one :inventory, dependent: :destroy
  has_one :handcard, dependent: :destroy
  has_one :monsterone, dependent: :destroy
  has_one :monstertwo, dependent: :destroy
  has_one :monsterthree, dependent: :destroy
  has_one :playercurse, dependent: :destroy
  belongs_to :user
  validates_uniqueness_of :user_id

  def init_player(_params = {})
    Inventory.find_or_create_by!(player: self)
    Monsterone.find_or_create_by!(player: self)
    Monstertwo.find_or_create_by!(player: self)
    Monsterthree.find_or_create_by!(player: self)
    Playercurse.find_or_create_by!(player: self)

    handcard = Handcard.find_or_create_by!(player: self)

    # add the monsters from the player to his handcards
    # TODO: Check if player actually posesses these cards
    Ingamedeck.create(card_id: user.monsterone, gameboard: gameboard, cardable: handcard) unless user.monsterone.blank?
    Ingamedeck.create(card_id: user.monstertwo, gameboard: gameboard, cardable: handcard) unless user.monstertwo.blank?
    Ingamedeck.create(card_id: user.monsterthree, gameboard: gameboard, cardable: handcard) unless user.monsterthree.blank?
  end

  def render_player
    monsters = []

    if monsterone.ingamedecks&.first
      monsters.push(
        Gameboard.render_user_monsters(self, 'Monsterone')
      )
    end
    if monstertwo.ingamedecks&.first
      monsters.push(
        Gameboard.render_user_monsters(self, 'Monstertwo')
      )
    end
    if monsterthree.ingamedecks&.first
      monsters.push(
        Gameboard.render_user_monsters(self, 'Monsterthree')
      )
    end

    { name: name, player_id: id, inventory: Gameboard.render_cards_array(inventory.ingamedecks), level: level, attack: attack,
      handcard: handcard.cards.count, monsters: monsters, playercurse: Gameboard.render_cards_array(playercurse.ingamedecks), user_id: user.id, intercept: intercept }
  end

  def self.broadcast_all_playerhandcards(gameboard)
    gameboard.players.each do |player|
      user = User.where(player: player).first

      PlayerChannel.broadcast_to(user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })
    end
  end

  def win_game(current_user)
    all_monsters = Monstercard.all
    random_monster = all_monsters.sample

    return if current_user.cards.size == all_monsters.size

    random_monster = all_monsters.sample while current_user.cards.find_by('id = ?', random_monster.id)

    current_user.cards << random_monster

    random_monster.id
  end

  def calculate_player_atk_with_monster_and_items
    monstercards1 = Monstercard.calculate_monsterslot_atk(monsterone.reload)
    monstercards2 = Monstercard.calculate_monsterslot_atk(monstertwo.reload)
    monstercards3 = Monstercard.calculate_monsterslot_atk(monsterthree.reload)

    atk = monstercards1 + monstercards2 + monstercards3 + reload.level

    update!(attack: atk)
    atk
  end
end
