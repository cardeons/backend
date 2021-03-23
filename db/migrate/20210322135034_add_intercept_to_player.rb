class AddInterceptToPlayer < ActiveRecord::Migration[6.1]
  def change
      add_column :players, :intercept, :boolean
  end
end
