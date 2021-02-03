require 'rails_helper'

RSpec.describe "centercards/show", type: :view do
  before(:each) do
    @centercard = assign(:centercard, Centercard.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
