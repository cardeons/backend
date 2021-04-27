class RemoveHelpingPlayerFromGameboard < ActiveRecord::Migration[6.1]
  def change
    remove_column :gameboards, :helping_player, :bigint
  end
end
