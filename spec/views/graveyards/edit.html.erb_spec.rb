require 'rails_helper'

RSpec.describe "graveyards/edit", type: :view do
  before(:each) do
    @graveyard = assign(:graveyard, Graveyard.create!(
      gameboard: nil,
      ingamedeck: nil
    ))
  end

  it "renders the edit graveyard form" do
    render

    assert_select "form[action=?][method=?]", graveyard_path(@graveyard), "post" do

      assert_select "input[name=?]", "graveyard[gameboard_id]"

      assert_select "input[name=?]", "graveyard[ingamedeck_id]"
    end
  end
end
