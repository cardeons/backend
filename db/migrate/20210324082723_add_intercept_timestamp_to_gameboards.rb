# frozen_string_literal: true
class AddInterceptTimestampToGameboards < ActiveRecord::Migration[6.1]
  def change
    add_column :gameboards, :intercept_timestamp, :timestamp
  end
end
