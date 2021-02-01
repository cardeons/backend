require 'rails_helper'

RSpec.describe "interceptcards/new", type: :view do
  before(:each) do
    assign(:interceptcard, Interceptcard.new(
      gameboard: nil,
      ingamedeck: nil
    ))
  end

  it "renders new interceptcard form" do
    render

    assert_select "form[action=?][method=?]", interceptcards_path, "post" do

      assert_select "input[name=?]", "interceptcard[gameboard_id]"

      assert_select "input[name=?]", "interceptcard[ingamedeck_id]"
    end
  end
end
