# frozen_string_literal: true

class RemoveOnlineFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :online, :boolean
  end
end
