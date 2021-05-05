# frozen_string_literal: true

class Levelcard < Card
  validates :title, :description, :image, :action, :type, :level_amount, presence: true

  def self.activate(ingamedeck, player)
    case ingamedeck.card.action # get the action from card
    when 'level_up'
      player.update(level: player.level + 1) unless player.level == 4
    when 'draw_two_cards'
      Handcard.draw_handcards(player.id, player.gameboard, 2)
      PlayerChannel.broadcast_to(player.user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })
    else
      puts "There is no action'"
    end
  end
end
