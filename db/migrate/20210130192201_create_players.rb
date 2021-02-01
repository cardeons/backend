# frozen_string_literal: true

class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string :name
      t.string :avatar
      t.integer :level
      t.integer :attack
      t.boolean :is_cursed
      t.references :gameboard, index: true, null: false, foreign_key: true

      t.timestamps
    end
  end
end
