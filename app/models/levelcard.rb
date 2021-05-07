# frozen_string_literal: true

class Levelcard < Card
  validates :title, :description, :image, :action, :type, :level_amount, presence: true

  def self.broadcast_gamelog(msg, gameboard)
    GameChannel.broadcast_to(gameboard, { type: 'GAME_LOG', params: { date: Time.new, message: msg, type: 'success' } })
  end

  def self.activate(params, current_user)
    ingamedeck = Ingamedeck.find_by('id = ?', params['unique_card_id'])
    player = current_user.player

    unless ingamedeck.card.type == 'Levelcard'
      PlayerChannel.broadcast_to(current_user, { type: 'ERROR', params: { message: "❌ You can't play this card here." } })
      return
    end
    case ingamedeck.card.action # get the action from card
    when 'level_up'
      # level up cards are not usable if you're one level before winning
      if player.level == 4
        PlayerChannel.broadcast_error(player.user, "❌ You can't use a level up card if you're already level 4!")
        return
      end
      player.update(level: player.level + 1)
      msg = "⬆ #{player.name} used a level up card! He is now level #{player.reload.level}."
      Levelcard.broadcast_gamelog(msg, player.gameboard)
      PlayerChannel.broadcast_to(player.user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.reload.ingamedecks) } })
      ingamedeck.update(cardable: player.gameboard.graveyard)
    when 'draw_two_cards'
      Handcard.draw_handcards(player.id, player.gameboard, 2)
      PlayerChannel.broadcast_to(player.user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.reload.ingamedecks) } })
      ingamedeck.update(cardable: player.gameboard.graveyard)
    else
      puts "❌ There is no action'"
    end
  end
end
