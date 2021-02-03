require 'rails_helper'

RSpec.describe "centercards/edit", type: :view do
  before(:each) do
    @centercard = assign(:centercard, Centercard.create!())
  end

  it "renders the edit centercard form" do
    render

    assert_select "form[action=?][method=?]", centercard_path(@centercard), "post" do
    end
  end
end
