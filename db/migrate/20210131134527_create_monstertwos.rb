# frozen_string_literal: true

class CreateMonstertwos < ActiveRecord::Migration[6.1]
  def change
    create_table :monstertwos do |t|
      # t.references :ingamedeck, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
