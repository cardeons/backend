require "application_system_test_case"

class MonsterthreesTest < ApplicationSystemTestCase
  setup do
    @monsterthree = monsterthrees(:one)
  end

  test "visiting the index" do
    visit monsterthrees_url
    assert_selector "h1", text: "Monsterthrees"
  end

  test "creating a Monsterthree" do
    visit monsterthrees_url
    click_on "New Monsterthree"

    fill_in "Ingamedeck", with: @monsterthree.ingamedeck_id
    fill_in "Player", with: @monsterthree.player_id
    click_on "Create Monsterthree"

    assert_text "Monsterthree was successfully created"
    click_on "Back"
  end

  test "updating a Monsterthree" do
    visit monsterthrees_url
    click_on "Edit", match: :first

    fill_in "Ingamedeck", with: @monsterthree.ingamedeck_id
    fill_in "Player", with: @monsterthree.player_id
    click_on "Update Monsterthree"

    assert_text "Monsterthree was successfully updated"
    click_on "Back"
  end

  test "destroying a Monsterthree" do
    visit monsterthrees_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Monsterthree was successfully destroyed"
  end
end
