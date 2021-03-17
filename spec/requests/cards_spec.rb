# frozen_string_literal: true

require 'rails_helper'


RSpec.describe 'Cards', type: :request do
  describe 'get /cards.json' do
    subject { get '/cards.json' }

    it 'returns success' do
      subject
      expect(response).to have_http_status(200)
    end

    it 'returns all available cards' do
      subject
      expect(JSON.parse(response.body).length).to be(Card.all.count)
    end
  end
end
