# frozen_string_literal: true

class Buffcard < Card
  validates :title, :description, :image, :action, :draw_chance, :atk_points, :type, presence: true

  def self.activate(card)
    case card.action # get the action from card
    when 'gain_atk'
      puts 'hi'
    when 'monster_lose_atk'
      puts 'hi'
    when 'plus_atk'
      puts 'hi'
    when 'dodge_monster'
      puts 'hi'
    when 'draw_two_cards'
      puts 'hi'
    when 'force_help'
      puts 'hi'
    when 'flee_success'
      puts 'hi'
    else
      puts "it was something else"
    end
  end
end
