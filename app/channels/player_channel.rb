# frozen_string_literal: true

class PlayerChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    broadcast_to(current_user, { type: DEBUG, params: { message: "you are now subscribed to the player Channel #{current_user.email}" } })
    broadcast_to(current_user,  { type: HANDCARD_UPDATE, params: { handcards:  Player.find(current_user.id).handcard.cards })

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
