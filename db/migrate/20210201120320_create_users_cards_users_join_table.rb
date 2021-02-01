# frozen_string_literal: true

class CreateUsersCardsUsersJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :users, :cards
  end
end
