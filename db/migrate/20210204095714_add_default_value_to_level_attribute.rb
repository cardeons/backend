class AddDefaultValueToLevelAttribute < ActiveRecord::Migration[6.1]
  def up
    change_column_default :players, :level, 1
    change_column_default :players, :attack, 1
    change_column_default :players, :is_cursed, false

  end

  def down
    change_column_default :players, :level, nil
    change_column_default :players, :attack, nil
    change_column_default :players, :is_cursed, nil
  end
  end
