# frozen_string_literal: true

class AddOldlobbyToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :oldlobby, :integer
  end
end
