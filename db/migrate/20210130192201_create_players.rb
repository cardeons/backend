class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string :name
      t.string :avatar
      t.integer :level
      t.integer :attack
      t.boolean :is_cursed
      t.gameboard :belongs_to

      t.timestamps
    end
  end
end
