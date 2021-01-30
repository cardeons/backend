require "test_helper"

class CardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @card = cards(:one)
  end

  test "should get index" do
    get cards_url
    assert_response :success
  end

  test "should get new" do
    get new_card_url
    assert_response :success
  end

  test "should create card" do
    assert_difference('Card.count') do
      post cards_url, params: { card: { action: @card.action, atk_points: @card.atk_points, bad_against: @card.bad_against, bad_against_value: @card.bad_against_value, bad_things: @card.bad_things, card_id: @card.card_id, description: @card.description, draw_chance: @card.draw_chance, element: @card.element, element_modifier: @card.element_modifier, good_against: @card.good_against, good_against_value: @card.good_against_value, has_combination: @card.has_combination, image: @card.image, item_category: @card.item_category, level: @card.level, level_amount: @card.level_amount, rewards_treasure: @card.rewards_treasure, title: @card.title } }
    end

    assert_redirected_to card_url(Card.last)
  end

  test "should show card" do
    get card_url(@card)
    assert_response :success
  end

  test "should get edit" do
    get edit_card_url(@card)
    assert_response :success
  end

  test "should update card" do
    patch card_url(@card), params: { card: { action: @card.action, atk_points: @card.atk_points, bad_against: @card.bad_against, bad_against_value: @card.bad_against_value, bad_things: @card.bad_things, card_id: @card.card_id, description: @card.description, draw_chance: @card.draw_chance, element: @card.element, element_modifier: @card.element_modifier, good_against: @card.good_against, good_against_value: @card.good_against_value, has_combination: @card.has_combination, image: @card.image, item_category: @card.item_category, level: @card.level, level_amount: @card.level_amount, rewards_treasure: @card.rewards_treasure, title: @card.title } }
    assert_redirected_to card_url(@card)
  end

  test "should destroy card" do
    assert_difference('Card.count', -1) do
      delete card_url(@card)
    end

    assert_redirected_to cards_url
  end
end
