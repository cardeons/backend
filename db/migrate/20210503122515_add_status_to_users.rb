# frozen_string_literal: true

class AddStatusToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :status, :integer
  end
end
