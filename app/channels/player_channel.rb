class PlayerChannel < ApplicationCable::Channel
  def subscribed
    

    stream_for current_user
    broadcast_to(current_user, "you are now getting updates to yourself #{current_user.email}")

    puts current_user

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
