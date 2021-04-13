class AddCurrentPlayerToGameboard < ActiveRecord::Migration[6.1]
  def change
    add_reference :gameboards, :player, index: true
  end
end
