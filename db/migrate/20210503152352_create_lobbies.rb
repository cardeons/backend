# frozen_string_literal: true

class CreateLobbies < ActiveRecord::Migration[6.1]
  def change
    create_table :lobbies, &:timestamps
  end
end
