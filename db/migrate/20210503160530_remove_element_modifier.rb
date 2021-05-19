# frozen_string_literal: true

class RemoveElementModifier < ActiveRecord::Migration[6.1]
  def change
    remove_column :cards, :element_modifier, :string
  end
end
