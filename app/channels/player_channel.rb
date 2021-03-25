# frozen_string_literal: true

class PlayerChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user

    player = Player.find_by('user_id = ?', current_user.id)
    broadcast_to(current_user, { type: 'DEBUG', params: { message: "you are now subscribed to the player Channel #{current_user.email}" } })
    broadcast_to(current_user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks) } })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def broadcast_all_playerhandcards(params)
    Player.broadcast_all_playerhandcards(params['gameboard'])
  end

  def self.broadcast_error(current_user, message)
    broadcast_to(current_user, { type: 'ERROR', params: { message: message } })
  end
end
