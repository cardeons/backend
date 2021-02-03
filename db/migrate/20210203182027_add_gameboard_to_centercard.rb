class AddGameboardToCentercard < ActiveRecord::Migration[6.1]
  def change
    add_reference :centercards, :gameboard, null: false, foreign_key: true
  end
end
