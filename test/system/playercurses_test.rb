require "application_system_test_case"

class PlayercursesTest < ApplicationSystemTestCase
  setup do
    @playercurse = playercurses(:one)
  end

  test "visiting the index" do
    visit playercurses_url
    assert_selector "h1", text: "Playercurses"
  end

  test "creating a Playercurse" do
    visit playercurses_url
    click_on "New Playercurse"

    fill_in "Ingamedeck", with: @playercurse.ingamedeck_id
    fill_in "Player", with: @playercurse.player_id
    click_on "Create Playercurse"

    assert_text "Playercurse was successfully created"
    click_on "Back"
  end

  test "updating a Playercurse" do
    visit playercurses_url
    click_on "Edit", match: :first

    fill_in "Ingamedeck", with: @playercurse.ingamedeck_id
    fill_in "Player", with: @playercurse.player_id
    click_on "Update Playercurse"

    assert_text "Playercurse was successfully updated"
    click_on "Back"
  end

  test "destroying a Playercurse" do
    visit playercurses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Playercurse was successfully destroyed"
  end
end
