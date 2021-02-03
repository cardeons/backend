class CreateCentercards < ActiveRecord::Migration[6.1]
  def change
    create_table :centercards do |t|

      t.timestamps
    end
  end
end
