# frozen_string_literal: true

class CreateCentercards < ActiveRecord::Migration[6.1]
  def change
    create_table :centercards, &:timestamps
  end
end
