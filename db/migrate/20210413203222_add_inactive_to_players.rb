# frozen_string_literal: true

class AddInactiveToPlayers < ActiveRecord::Migration[6.1]
  def change
    add_column :players, :inactive, :boolean, default: false
  end
end
