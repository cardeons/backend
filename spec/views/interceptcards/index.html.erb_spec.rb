require 'rails_helper'

RSpec.describe "interceptcards/index", type: :view do
  before(:each) do
    assign(:interceptcards, [
      Interceptcard.create!(
        gameboard: nil,
        ingamedeck: nil
      ),
      Interceptcard.create!(
        gameboard: nil,
        ingamedeck: nil
      )
    ])
  end

  it "renders a list of interceptcards" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
  end
end
