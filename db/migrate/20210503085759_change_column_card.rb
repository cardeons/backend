class ChangeColumnCard < ActiveRecord::Migration[6.1]
  def up
    change_column :cards, :good_against, 'numeric USING CAST(good_against AS numeric)'
    change_column :cards, :bad_against, 'numeric USING CAST(good_against AS numeric)'
    change_column :cards, :element, 'numeric USING CAST(good_against AS numeric)'
    add_column :cards, :animal, :integer
  end

  def down
    change_column :cards, :good_against, :string
    change_column :cards, :bad_against, :string
    change_column :cards, :element, :string
  end
end
