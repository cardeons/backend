require 'rails_helper'

RSpec.describe "centercards/index", type: :view do
  before(:each) do
    assign(:centercards, [
      Centercard.create!(),
      Centercard.create!()
    ])
  end

  it "renders a list of centercards" do
    render
  end
end
