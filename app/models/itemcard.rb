# frozen_string_literal: true

class Itemcard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :item_category, :type, presence: true

  def self.activate(card)
    case card.action # get the action from card
    when 'plus_3_if_combination'
      puts 'it was 1'
    when 'plus_three'
      puts 'asd'
    when 'plus_two'
      puts 'asd'
    else
      puts 'it was something else'
    end
  end

  # returns synergy value of given card_to_compare_against
  def calculate_synergy_value(card_to_compare_against)
    return 0 if card_to_compare_against&.animal != synergy_type

    synergy_value
  end
end
