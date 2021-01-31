class CreateIngamedecks < ActiveRecord::Migration[6.1]
  def change
    create_table :ingamedecks do |t|
      t.references :card, null: false, foreign_key: true
      t.references :gameboard, null: false, foreign_key: true
      t.references :cardable, polymorphic: true

      t.timestamps
    end
  end
end
