# frozen_string_literal: true

class CheckIntercepttimerJob < ApplicationJob
  queue_as :default

  def perform(gameboard, timestamp, intercept_delay = 45)
    gameboard.reload

    # TODO: Prevent Race Conditions!!!
    timestamp_int = timestamp.to_i
    intercept_delay_int = intercept_delay.to_i
    time_int = Time.new.to_i

    if (gameboard.intercept_phase? || gameboard.boss_phase?) && (time_int - timestamp_int.to_i) > intercept_delay_int.to_i
      GameChannel.broadcast_to(gameboard, { type: 'DEBUG', params: { message: "You just activated my job ;) with a delay of #{timestamp_int - time_int}" } })
      gameboard.intercept_phase? ? gameboard.intercept_finished! : gameboard.boss_phase_finished!

      gameboard.intercept_timestamp = nil
      gameboard.reload.save!
      GameChannel.broadcast_to(gameboard, { type: 'GAME_LOG', params: { date: Time.new, message: '📢 Intercept Phase is finished', type: 'info' } })

      if gameboard.boss_phase_finished?
        result = Gameboard.calc_attack_points(gameboard.reload)

        # win
        if result[:result]
          pp 'WIIIIIIIIINNNNNNNNNNNn'
          gameboard.boss_phase_finished!
          GameChannel.broadcast_to(gameboard, { type: 'BOARD_UPDATE', params: Gameboard.broadcast_game_board(gameboard.reload) })
          msg = "😎 You all defeated #{gameboard.centercard.card.title}!"
          GameChannel.broadcast_to(gameboard, { type: 'GAME_LOG', params: { date: Time.new, message: msg, type: 'success' } })

          gameboard.players.each do |player|
            Handcard.draw_handcards(player.id, gameboard, gameboard.centercard.card.rewards_treasure.to_i)
            PlayerChannel.broadcast_to(player.user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.reload.ingamedecks) } })
          end

          gameboard.centercard.ingamedeck&.update!(cardable: gameboard.graveyard)
          # sleep for frontend animation
          # could maybe be shorter as soon as we know the animation length (kinda)
          sleep 1

          Gameboard.get_next_player(gameboard)
          gameboard.ingame!
          GameChannel.broadcast_to(gameboard, { type: 'BOARD_UPDATE', params: Gameboard.broadcast_game_board(gameboard.reload) })
        else
          # loss
          Monstercard.bad_things(gameboard.centercard, gameboard)
        end

      end
      GameChannel.broadcast_to(gameboard, { type: 'BOARD_UPDATE', params: Gameboard.broadcast_game_board(gameboard) })

    elsif (gameboard.intercept_phase? || gameboard.boss_phase?) && gameboard.intercept_timestamp.to_i == timestamp_int
      CheckIntercepttimerJob.perform_later(gameboard, timestamp_int, intercept_delay_int)
    end
  end
end
