# frozen_string_literal: true

class AddLobbyToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :lobby, index: true, foreign_key: true
  end
end
