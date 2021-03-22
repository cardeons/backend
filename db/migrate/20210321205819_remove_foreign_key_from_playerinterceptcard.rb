class RemoveForeignKeyFromPlayerinterceptcard < ActiveRecord::Migration[6.1]
  def change
    remove_reference :playerinterceptcards, :ingamedeck, index: true, foreign_key: true
  end
end
