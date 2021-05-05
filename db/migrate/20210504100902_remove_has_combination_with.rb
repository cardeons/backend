# frozen_string_literal: true

class RemoveHasCombinationWith < ActiveRecord::Migration[6.1]
  def change
    remove_column :cards, :has_combination
  end
end
