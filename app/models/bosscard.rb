class Bosscard < Card
    validates :title, :description, :image, :action, :draw_chance, :level, :element, :bad_things, :rewards_treasure, :good_aginst, :bad_against, :good_aginst_value, :bad_against_value, :atk_points, :level_amount, :type, presence: true
end
