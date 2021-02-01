# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'graveyards/show', type: :view do
  before(:each) do
    @graveyard = assign(:graveyard, Graveyard.create!(
                                      gameboard: nil,
                                      ingamedeck: nil
                                    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
