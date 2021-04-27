# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  pending "add some examples to (or delete) #{__FILE__}"

  # fixtures :users
  # before { @user = users(:one) }
  # path '/users.json' do
  #   get 'list all the users' do
  #     tags 'User'

  #     produces 'application/json'

  #     response(200, 'successful') do
  #       schema type: :array,
  #              items: {
  #                type: :object,
  #                properties: {
  #                  id: { type: :integer },
  #                  name: { type: :string },
  #                  email: { type: :string }
  #                },
  #                required: %w[id name email]
  #              }

  #       run_test!
  #     end
  #   end
  # end

  # path '/users/{id}.json' do
  #   get 'show user' do
  #     tags 'User'

  #     produces 'application/json'
  #     parameter name: 'id', in: :path, type: :string

  #     response 200, 'successful' do
  #       schema type: :object,
  #              properties: {
  #                id: { type: :integer },
  #                name: { type: :string },
  #                email: { type: :string }
  #              },
  #              required: %w[id name email]

  #       let(:id) do
  #         u = User.create!(name: 'Luke', email: 'luke@skywalker.net', password: '1234567', password_confirmation: '1234567')
  #         u.id
  #       end

  #       run_test!
  #     end
  #   end
  # end

  # path '/registrations' do
  #   post 'Creates a user' do
  #     tags 'User'

  #     consumes 'application/json'
  #     produces 'application/json'
  #     parameter name: :user,
  #               in: :body,
  #               schema: {
  #                 type: :object,
  #                 properties: {
  #                   name: { type: :string },
  #                   email: { type: :string },
  #                   password: { type: :string },
  #                   password_confirmation: { type: :string }
  #                 }, required: %w[name email password]
  #               }
  #     response '201', 'user created' do
  #       let(:user) do
  #         { data: { type: 'user', attributes: { name: 'Good', email: 'good@hier.com', password: 'asecret' } } }
  #       end
  #       run_test!
  #       after do |example|
  #         example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
  #       end
  #     end

  #     response '422', "password can't be blank, name can't exist, e-mail can't exist" do
  #       let(:user) do
  #         u = User.first
  #         { data: { type: 'user', attributes: { name: u.name, email: u.email } } }
  #       end
  #       run_test!
  #       after do |example|
  #         example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
  #       end
  #     end
  #   end
  # end

  # path '/sessions' do
  #   post 'Logs in a user' do
  #     tags 'User'

  #     consumes 'application/json'
  #     produces 'application/json'
  #     parameter name: :user,
  #               in: :body,
  #               schema: {
  #                 type: :object,
  #                 properties: {
  #                   email: { type: :string },
  #                   password: { type: :string }
  #                 }, required: %w[email password]
  #               }
  #     response '200', 'user logged in' do
  #       let(:user) do
  #         { data: { type: 'user', attributes: { email: 'testi@test.aqt', password: 'string' } } }
  #       end
  #       run_test!
  #       after do |example|
  #         example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
  #       end
  #     end
  #   end
  # end
end
