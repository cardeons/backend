class AddRewardsToGameboard < ActiveRecord::Migration[6.1]
  def change
    add_column :gameboards, :rewards_treasure, :integer
  end
end
