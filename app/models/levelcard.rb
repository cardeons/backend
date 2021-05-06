# frozen_string_literal: true

class Levelcard < Card
  validates :title, :description, :image, :action, :type, :level_amount, presence: true

  def self.activate(params, current_user)
    ingamedeck = Ingamedeck.find_by('id = ?', params['unique_card_id'])
    player = current_user.player

    unless ingamedeck.card.type == 'Levelcard'
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "❌ You can't play this card here." } })
      return
    end
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
