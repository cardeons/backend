# frozen_string_literal: true

class RemoveForeignKeyFromGraveyard < ActiveRecord::Migration[6.1]
  def change
    remove_reference :graveyards, :ingamedeck, index: true, foreign_key: true
  end
end
