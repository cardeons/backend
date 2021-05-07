# frozen_string_literal: true

class AddStateToGameboard < ActiveRecord::Migration[6.1]
  def up
    remove_column :gameboards, :current_state
    add_column :gameboards, :current_state, :integer, default: 0
  end

  def down
    remove_column :gameboards, :current_state
    add_column :gameboards, :current_state, :integer
  end
end
