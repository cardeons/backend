# frozen_string_literal: true

class CheckIntercepttimerJob < ApplicationJob
  queue_as :default

  def perform(gameboard_id, timestamp)
    pp 'JOB'
    pp '_________________________________________________________'

    pp gameboard_id
    pp Gameboard.all
    gameboard = Gameboard.find_by('id=?', gameboard_id)

    pp gameboard

    GameChannel.broadcast_to(gameboard, { type: 'DEBUG', params: { message: "You just activated my job ;) with a delay of #{timestamp - Time.new}" } }) if gameboard

    # gameboard = Gameboard.find_by('id=?', gameboard_id)
    # if gameboard.last_intercept_ts != timestamp
    #   nil
    # else
    #   GameChannel.broadcast_to(gameboard, 'Intercept is over')
    # end
  end
end
