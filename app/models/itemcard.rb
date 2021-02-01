class Itemcard < Card
    validates :title, :description, :image, :action, :draw_chance, :element, :element_modifier, :atk_points, :has_combination, :item_category, :type, presence: true
end
