# frozen_string_literal: true

class CreateMonsterones < ActiveRecord::Migration[6.1]
  def change
    create_table :monsterones do |t|
      # t.references :ingamedeck, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
