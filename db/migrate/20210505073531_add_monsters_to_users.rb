# frozen_string_literal: true

class AddMonstersToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :monsterone, :integer
    add_column :users, :monstertwo, :integer
    add_column :users, :monsterthree, :integer
  end
end
