# frozen_string_literal: true

class CreateGameboards < ActiveRecord::Migration[6.1]
  def change
    create_table :gameboards do |t|
      t.string :current_state
      t.integer :player_atk
      t.integer :monster_atk
      t.boolean :asked_help
      t.boolean :success
      t.boolean :can_flee
      t.integer :shared_reward

      t.timestamps
    end
  end
end
