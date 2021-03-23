# frozen_string_literal: true

class Levelcard < Card
  validates :title, :description, :image, :action, :type, :level_amount, presence: true

  def self.activate(card, player)
    case card.action # get the action from card
    when 'level_up'
      player.update(level: player.level + 1) unless player.level == 4
    else
      puts "There is no action'"
    end
  end
end
