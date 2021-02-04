# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'centercards/new', type: :view do
  before(:each) do
    assign(:centercard, Centercard.new)
  end

  it 'renders new centercard form' do
    render

    assert_select 'form[action=?][method=?]', centercards_path, 'post' do
    end
  end
end
