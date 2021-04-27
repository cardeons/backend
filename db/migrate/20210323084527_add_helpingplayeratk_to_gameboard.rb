# frozen_string_literal: true

class AddHelpingplayeratkToGameboard < ActiveRecord::Migration[6.1]
  def change
    add_column :gameboards, :helping_player_atk, :int, default: 0
  end
end
