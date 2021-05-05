# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Inventory API', type: :request do
  pending "add some examples to (or delete) #{__FILE__}"

  # fixtures :users
  # before { @user = users(:one) }
  # path '/users/{id}/inventory.json' do
  #   get 'list all cards of user' do
  #     tags 'Inventory'

  #     consumes 'application/json'
  #     produces 'application/json'

  #     parameter name: 'id', in: :path, type: :string

  #     response(200, 'successful') do
  #       schema type: :array,
  #              items: {
  #                type: :object,
  #                properties: {
  #                  data: {
  #                    type: :array,
  #                    items: {
  #                      type: :object,
  #                      properties: {
  #                        id: { type: :string },
  #                        title: { type: :string },
  #                        type: { type: :string },
  #                        description: { type: :string },
  #                        image: { type: :string },
  #                        action: { type: :string },
  #                        draw_chance: { type: :string },
  #                        level: { type: :string },
  #                        element: { type: :string },
  #                        bad_things: { type: :string },
  #                        rewards_treasure: { type: :string },
  #                        good_against: { type: :string },
  #                        bad_against: { type: :string },
  #                        good_against_value: { type: :string },
  #                        bad_against_value: { type: :string },
  #                        atk_points: { type: :string },
  #                        item_category: { type: :string },
  #                        level_amount: { type: :string },
  #                        created_at: { type: :string },
  #                        updated_at: { type: :string },
  #                        url: { type: :string }
  #                      },
  #                      required: %w[id]
  #                    }
  #                  }
  #                }
  #              }

  #       run_test!
  #     end
  #   end
  # end
end
