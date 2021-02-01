# frozen_string_literal: true

class CreateHandcards < ActiveRecord::Migration[6.1]
  def change
    create_table :handcards do |t|
      # t.references :ingamedeck, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
