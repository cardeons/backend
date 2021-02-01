# frozen_string_literal: true

class AddTypeToCards < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :type, :string
  end
end
