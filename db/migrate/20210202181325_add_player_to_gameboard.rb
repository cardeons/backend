# frozen_string_literal: true

class AddPlayerToGameboard < ActiveRecord::Migration[6.1]
  def change
    add_reference :gameboards, :player, foreign_key: true
  end
end
