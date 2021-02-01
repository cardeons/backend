require 'rails_helper'

RSpec.describe "graveyards/new", type: :view do
  before(:each) do
    assign(:graveyard, Graveyard.new(
      gameboard: nil,
      ingamedeck: nil
    ))
  end

  it "renders new graveyard form" do
    render

    assert_select "form[action=?][method=?]", graveyards_path, "post" do

      assert_select "input[name=?]", "graveyard[gameboard_id]"

      assert_select "input[name=?]", "graveyard[ingamedeck_id]"
    end
  end
end
