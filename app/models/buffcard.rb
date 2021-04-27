# frozen_string_literal: true

class Buffcard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :type, presence: true

  def self.activate(ingamedeck, player, gameboard)
    case ingamedeck.card.action # get the action from card
    when 'gain_atk'
      gameboard.update(player_atk: gameboard.player_atk + ingamedeck.card.atk_points)

      ingamedeck.update(cardable: gameboard.graveyard)
    when 'monster_lose_atk'
      gameboard.update(monster_atk: gameboard.monster_atk + ingamedeck.card.atk_points)

      ingamedeck.update(cardable: gameboard.graveyard)
    when 'plus_atk'
      # TODO: Check if monster or player gets buff??
      gameboard.update(player_atk: gameboard.player_atk + ingamedeck.card.atk_points)

      ingamedeck.update(cardable: gameboard.graveyard)
    when 'dodge_monster'
      gameboard.update(can_flee: true)
    when 'draw_two_cards'
      Handcard.draw_handcards(player.id, gameboard, 2)
    when 'force_help'
      helping_player_id = gameboard.helping_player
      helping_player = Player.find_by('id = ?', helping_player_id)

      gameboard.update(helping_player_atk: helping_player&.attack)
    when 'flee_success'
      gameboard.update(can_flee: true)
    else
      puts 'it was something else'
    end
  end
end
