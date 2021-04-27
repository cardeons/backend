# frozen_string_literal: true

class Itemcard < Card
  validates :title, :description, :image, :action, :draw_chance, :element, :element_modifier, :atk_points, :has_combination, :item_category, :type, presence: true

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
end
