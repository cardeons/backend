# frozen_string_literal: true

require 'application_system_test_case'

class IngamedecksTest < ApplicationSystemTestCase
  setup do
    @ingamedeck = ingamedecks(:one)
  end

  test 'visiting the index' do
    visit ingamedecks_url
    assert_selector 'h1', text: 'Ingamedecks'
  end

  test 'creating a Ingamedeck' do
    visit ingamedecks_url
    click_on 'New Ingamedeck'

    fill_in 'Card', with: @ingamedeck.card_id
    fill_in 'Gameboard', with: @ingamedeck.gameboard_id
    click_on 'Create Ingamedeck'

    assert_text 'Ingamedeck was successfully created'
    click_on 'Back'
  end

  test 'updating a Ingamedeck' do
    visit ingamedecks_url
    click_on 'Edit', match: :first

    fill_in 'Card', with: @ingamedeck.card_id
    fill_in 'Gameboard', with: @ingamedeck.gameboard_id
    click_on 'Update Ingamedeck'

    assert_text 'Ingamedeck was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Ingamedeck' do
    visit ingamedecks_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Ingamedeck was successfully destroyed'
  end
end
