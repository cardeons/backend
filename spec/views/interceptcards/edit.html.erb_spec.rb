# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'interceptcards/edit', type: :view do
  before(:each) do
    @interceptcard = assign(:interceptcard, Interceptcard.create!(
                                              gameboard: nil,
                                              ingamedeck: nil
                                            ))
  end

  it 'renders the edit interceptcard form' do
    render

    assert_select 'form[action=?][method=?]', interceptcard_path(@interceptcard), 'post' do
      assert_select 'input[name=?]', 'interceptcard[gameboard_id]'

      assert_select 'input[name=?]', 'interceptcard[ingamedeck_id]'
    end
  end
end
