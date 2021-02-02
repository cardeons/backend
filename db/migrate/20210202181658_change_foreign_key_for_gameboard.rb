class ChangeForeignKeyForGameboard < ActiveRecord::Migration[6.1]
  def change
    rename_column :gameboards, :player_id, :current_player
  end
end
