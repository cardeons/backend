class Monstercard < Card
    validates :title, :description, :image, :action, :draw_chance, :level, :element, :bad_things, :rewards_treasure, :atk_points, :level_amount, :type, presence: true
end
