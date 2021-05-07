# frozen_string_literal: true

class AddModifierToGameboard < ActiveRecord::Migration[6.1]
  def change
    add_column :gameboards, :player_element_synergy_modifiers, :integer, default: 0, null: false
    add_column :gameboards, :monster_element_synergy_modifiers, :integer, default: 0, null: false
  end
end
