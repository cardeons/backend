# frozen_string_literal: true

class Bosscard < Card
  validates :title, :description, :image, :action, :draw_chance, :level, :bad_things, :rewards_treasure, :atk_points, :level_amount, :type, presence: true
end
