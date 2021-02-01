require 'rails_helper'

RSpec.describe "interceptcards/show", type: :view do
  before(:each) do
    @interceptcard = assign(:interceptcard, Interceptcard.create!(
      gameboard: nil,
      ingamedeck: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
