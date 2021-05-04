# frozen_string_literal: true

class Levelcard < Card
  validates :title, :description, :image, :action, :type, :level_amount, presence: true

  def self.activate(ingamedeck, player)
    case ingamedeck.card.action # get the action from card
    when 'level_up'
      player.update(level: player.level + 1) unless player.level == 4
      msg = "#{player.name} used a level up card! He is now level #{player.reload.level}."
      Cursecard.broadcast_gamelog(msg, player.gameboard)
    else
      puts "There is no action'"
    end
  end
end
