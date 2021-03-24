class AddStateToGameboard < ActiveRecord::Migration[6.1]
  def change
    remove_column :gameboards, :current_state
    add_column :gameboards, :current_state, :integer, default: 0
  end
end
