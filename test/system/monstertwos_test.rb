require "application_system_test_case"

class MonstertwosTest < ApplicationSystemTestCase
  setup do
    @monstertwo = monstertwos(:one)
  end

  test "visiting the index" do
    visit monstertwos_url
    assert_selector "h1", text: "Monstertwos"
  end

  test "creating a Monstertwo" do
    visit monstertwos_url
    click_on "New Monstertwo"

    fill_in "Ingamedeck", with: @monstertwo.ingamedeck_id
    fill_in "Player", with: @monstertwo.player_id
    click_on "Create Monstertwo"

    assert_text "Monstertwo was successfully created"
    click_on "Back"
  end

  test "updating a Monstertwo" do
    visit monstertwos_url
    click_on "Edit", match: :first

    fill_in "Ingamedeck", with: @monstertwo.ingamedeck_id
    fill_in "Player", with: @monstertwo.player_id
    click_on "Update Monstertwo"

    assert_text "Monstertwo was successfully updated"
    click_on "Back"
  end

  test "destroying a Monstertwo" do
    visit monstertwos_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Monstertwo was successfully destroyed"
  end
end
