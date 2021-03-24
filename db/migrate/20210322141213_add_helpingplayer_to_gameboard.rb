# frozen_string_literal: true

class AddHelpingplayerToGameboard < ActiveRecord::Migration[6.1]
  def change
    add_column :gameboards, :helping_player, :bigint
  end
end
