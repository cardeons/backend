# frozen_string_literal: true

class Levelcard < Card
  validates :title, :description, :image, :action, :type, :level_amount, presence: true

  def self.broadcast_gamelog(msg, gameboard)
    GameChannel.broadcast_to(gameboard, { type: 'GAME_LOG', params: { date: Time.new, message: msg, type: 'warning' } })
  end

  def self.activate(ingamedeck, player)
    case ingamedeck.card.action # get the action from card
    when 'level_up'
      # level up cards are not usable if you're one level before winning
      if player.level == 4
        PlayerChannel.broadcast_error(player.user, "You can't use a level up card if you're already level 4!")
        return
      end
      player.update(level: player.level + 1)
      msg = "#{player.name} used a level up card! He is now level #{player.reload.level}."
      Levelcard.broadcast_gamelog(msg, player.gameboard)
    else
      puts "There is no action'"
    end
  end
end
