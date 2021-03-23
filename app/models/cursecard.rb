# frozen_string_literal: true

class Cursecard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :type, presence: true

  def self.activate(card)
    case card.action # get the action from card
    when 'lose_atk_points'
      puts "it was 1" 
    when 'lose_item_hand'
      puts "it was 2"
    when 'no_help_next_fight'
      puts 'hi'
    when 'minus_atk_next_fight'
      puts 'hi'
    when 'lose_item_head'
      puts 'uwu'
    when 'lose_level'
      puts 'uwu'
    when 'double_attack_double_reward'
      puts 'hi'
    else
      puts "it was something else"
    end
  end
end
