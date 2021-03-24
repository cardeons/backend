# frozen_string_literal: true

class CheckIntercepttimerJob < ApplicationJob
  queue_as :default

  def perform(gameboard, timestamp, intercept_delay = 15)
    gameboard.reload

    # TODO: Prevent Race Conditions!!!
    timestamp_int = timestamp.to_i
    intercept_delay_int = intercept_delay.to_i
    time_int = Time.new.to_i

    if gameboard.intercept_phase? && (time_int - timestamp_int.to_i) > intercept_delay_int.to_i
      GameChannel.broadcast_to(gameboard, { type: 'DEBUG', params: { message: "You just activated my job ;) with a delay of #{timestamp_int - time_int}" } })
      gameboard.intercept_finished!
      gameboard.intercept_timestamp = nil
      gameboard.save!
      GameChannel.broadcast_to(gameboard, { type: 'GAME_LOG', params: { date: Time.new, message: 'Intercept Phase is finished' } })
      GameChannel.broadcast_to(gameboard, { type: 'BOARD_UPDATE', params: Gameboard.broadcast_game_board(gameboard) })
    elsif gameboard.intercept_phase? && gameboard.intercept_timestamp.to_i == timestamp_int
      CheckIntercepttimerJob.perform_later(gameboard, timestamp_int, intercept_delay_int)
    end
  end
end
