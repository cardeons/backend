class AddDefaultToPlayerIntercept < ActiveRecord::Migration[6.1]
  def up
    change_column_default :players, :intercept, true
  end

  def down
    change_column_default :players, :intercept, nil
  end
end
