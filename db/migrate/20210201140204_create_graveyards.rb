# frozen_string_literal: true

class CreateGraveyards < ActiveRecord::Migration[6.1]
  def change
    create_table :graveyards do |t|
      t.references :gameboard, null: false, foreign_key: true
      t.references :ingamedeck, null: false, foreign_key: true

      t.timestamps
    end
  end
end
