# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'graveyards/index', type: :view do
  before(:each) do
    assign(:graveyards, [
             Graveyard.create!(
               gameboard: nil,
               ingamedeck: nil
             ),
             Graveyard.create!(
               gameboard: nil,
               ingamedeck: nil
             )
           ])
  end

  it 'renders a list of graveyards' do
    render
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
  end
end
