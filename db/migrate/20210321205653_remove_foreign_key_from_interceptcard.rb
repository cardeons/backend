# frozen_string_literal: true

class RemoveForeignKeyFromInterceptcard < ActiveRecord::Migration[6.1]
  def change
    remove_reference :interceptcards, :ingamedeck, index: true, foreign_key: true
  end
end
