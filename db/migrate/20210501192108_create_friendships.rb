# frozen_string_literal: true

class CreateFriendships < ActiveRecord::Migration[6.1]
  def change
    create_table :friendships do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :friend_id

      t.timestamps
    end
  end
end
