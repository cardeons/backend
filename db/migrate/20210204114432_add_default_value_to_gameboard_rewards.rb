# frozen_string_literal: true

class AddDefaultValueToGameboardRewards < ActiveRecord::Migration[6.1]
  def up
    change_column_default :gameboards, :rewards_treasure, 0
  end

  def down
    change_column_default :gameboards, :rewards_treasure, nil
  end
end
