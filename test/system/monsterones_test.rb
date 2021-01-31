require "application_system_test_case"

class MonsteronesTest < ApplicationSystemTestCase
  setup do
    @monsterone = monsterones(:one)
  end

  test "visiting the index" do
    visit monsterones_url
    assert_selector "h1", text: "Monsterones"
  end

  test "creating a Monsterone" do
    visit monsterones_url
    click_on "New Monsterone"

    fill_in "Ingamedeck", with: @monsterone.ingamedeck_id
    fill_in "Player", with: @monsterone.player_id
    click_on "Create Monsterone"

    assert_text "Monsterone was successfully created"
    click_on "Back"
  end

  test "updating a Monsterone" do
    visit monsterones_url
    click_on "Edit", match: :first

    fill_in "Ingamedeck", with: @monsterone.ingamedeck_id
    fill_in "Player", with: @monsterone.player_id
    click_on "Update Monsterone"

    assert_text "Monsterone was successfully updated"
    click_on "Back"
  end

  test "destroying a Monsterone" do
    visit monsterones_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Monsterone was successfully destroyed"
  end
end
