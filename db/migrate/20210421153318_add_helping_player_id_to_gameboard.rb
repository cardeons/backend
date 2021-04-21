class AddHelpingPlayerIdToGameboard < ActiveRecord::Migration[6.1]
  def change
    add_column :gameboards, :helping_player_id, :bigint
  end
end
