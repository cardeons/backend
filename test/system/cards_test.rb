# frozen_string_literal: true

require 'application_system_test_case'

class CardsTest < ApplicationSystemTestCase
  setup do
    @card = cards(:one)
  end

  test 'visiting the index' do
    visit cards_url
    assert_selector 'h1', text: 'Cards'
  end

  test 'creating a Card' do
    visit cards_url
    click_on 'New Card'

    fill_in 'Action', with: @card.action
    fill_in 'Atk points', with: @card.atk_points
    fill_in 'Bad against', with: @card.bad_against
    fill_in 'Bad against value', with: @card.bad_against_value
    fill_in 'Bad things', with: @card.bad_things
    fill_in 'Card', with: @card.card_id
    fill_in 'Description', with: @card.description
    fill_in 'Draw chance', with: @card.draw_chance
    fill_in 'Element', with: @card.element
    fill_in 'Element modifier', with: @card.element_modifier
    fill_in 'Good against', with: @card.good_against
    fill_in 'Good against value', with: @card.good_against_value
    fill_in 'Has combination', with: @card.has_combination
    fill_in 'Image', with: @card.image
    fill_in 'Item category', with: @card.item_category
    fill_in 'Level', with: @card.level
    fill_in 'Level amount', with: @card.level_amount
    fill_in 'Rewards treasure', with: @card.rewards_treasure
    fill_in 'Title', with: @card.title
    click_on 'Create Card'

    assert_text 'Card was successfully created'
    click_on 'Back'
  end

  test 'updating a Card' do
    visit cards_url
    click_on 'Edit', match: :first

    fill_in 'Action', with: @card.action
    fill_in 'Atk points', with: @card.atk_points
    fill_in 'Bad against', with: @card.bad_against
    fill_in 'Bad against value', with: @card.bad_against_value
    fill_in 'Bad things', with: @card.bad_things
    fill_in 'Card', with: @card.card_id
    fill_in 'Description', with: @card.description
    fill_in 'Draw chance', with: @card.draw_chance
    fill_in 'Element', with: @card.element
    fill_in 'Element modifier', with: @card.element_modifier
    fill_in 'Good against', with: @card.good_against
    fill_in 'Good against value', with: @card.good_against_value
    fill_in 'Has combination', with: @card.has_combination
    fill_in 'Image', with: @card.image
    fill_in 'Item category', with: @card.item_category
    fill_in 'Level', with: @card.level
    fill_in 'Level amount', with: @card.level_amount
    fill_in 'Rewards treasure', with: @card.rewards_treasure
    fill_in 'Title', with: @card.title
    click_on 'Update Card'

    assert_text 'Card was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Card' do
    visit cards_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Card was successfully destroyed'
  end
end
