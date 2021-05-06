# frozen_string_literal: true

class AddPendingToFriendships < ActiveRecord::Migration[6.1]
  def change
    add_column :friendships, :pending, :boolean, default: true
  end
end
