# frozen_string_literal: true

class Buffcard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :type, presence: true

  def self.broadcast_gamelog(msg, gameboard)
    GameChannel.broadcast_to(gameboard, { type: 'GAME_LOG', params: { date: Time.new, message: msg, type: 'warning' } })
  end
end
