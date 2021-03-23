class ChangeDefaultValueFromInterceptToFalse < ActiveRecord::Migration[6.1]
  def change
    change_column_default :players, :intercept, from: true, to: false
  end
end
