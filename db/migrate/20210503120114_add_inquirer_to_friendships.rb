class AddInquirerToFriendships < ActiveRecord::Migration[6.1]
  def change
    add_column :friendships, :inquirer_id, :bigint
  end
end
