# frozen_string_literal: true

class Cursecard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :type, presence: true
end
