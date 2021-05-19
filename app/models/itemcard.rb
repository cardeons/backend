# frozen_string_literal: true

class Itemcard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :item_category, :type, presence: true

  # returns synergy value of given card_to_compare_against
  def calculate_synergy_value(card_to_compare_against)
    return 0 if card_to_compare_against&.animal != synergy_type

    synergy_value
  end
end
