# frozen_string_literal: true

class CreateCards < ActiveRecord::Migration[6.1]
  def change
    create_table :cards do |t|
      t.string :title
      t.string :description
      t.string :image
      t.string :action
      t.integer :draw_chance
      t.integer :level
      t.string :element
      t.string :bad_things
      t.string :rewards_treasure
      t.string :good_against
      t.string :bad_against
      t.integer :good_against_value
      t.integer :bad_against_value
      t.integer :element_modifier
      t.integer :atk_points
      t.string :item_category
      t.integer :level_amount
      t.integer :has_combination
      t.timestamps
    end
  end
end
