class ChangeColumnCard < ActiveRecord::Migration[6.1]
  def up
    change_column :cards, :good_against, 'numeric USING CAST(good_against AS numeric)'
    change_column :cards, :bad_against, 'numeric USING CAST(good_against AS numeric)'
    change_column :cards, :element, 'numeric USING CAST(good_against AS numeric)'
    add_column :cards, :synergy_type, :integer, if_not_exists: true
    add_column :cards, :synergy_value, :integer, default: 0
  end

  def down
    change_column :cards, :good_against, :string
    change_column :cards, :bad_against, :string
    change_column :cards, :element, :string
    remove_column :cards, :synergy_type
    remove_column :cards, :synergy_value
  end
end
