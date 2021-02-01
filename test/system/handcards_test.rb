# frozen_string_literal: true

require 'application_system_test_case'

class HandcardsTest < ApplicationSystemTestCase
  setup do
    @handcard = handcards(:one)
  end

  test 'visiting the index' do
    visit handcards_url
    assert_selector 'h1', text: 'Handcards'
  end

  test 'creating a Handcard' do
    visit handcards_url
    click_on 'New Handcard'

    fill_in 'Ingamedeck', with: @handcard.ingamedeck_id
    fill_in 'Player', with: @handcard.player_id
    click_on 'Create Handcard'

    assert_text 'Handcard was successfully created'
    click_on 'Back'
  end

  test 'updating a Handcard' do
    visit handcards_url
    click_on 'Edit', match: :first

    fill_in 'Ingamedeck', with: @handcard.ingamedeck_id
    fill_in 'Player', with: @handcard.player_id
    click_on 'Update Handcard'

    assert_text 'Handcard was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Handcard' do
    visit handcards_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Handcard was successfully destroyed'
  end
end
