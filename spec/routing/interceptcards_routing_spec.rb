# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InterceptcardsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/interceptcards').to route_to('interceptcards#index')
    end

    it 'routes to #new' do
      expect(get: '/interceptcards/new').to route_to('interceptcards#new')
    end

    it 'routes to #show' do
      expect(get: '/interceptcards/1').to route_to('interceptcards#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/interceptcards/1/edit').to route_to('interceptcards#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/interceptcards').to route_to('interceptcards#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/interceptcards/1').to route_to('interceptcards#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/interceptcards/1').to route_to('interceptcards#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/interceptcards/1').to route_to('interceptcards#destroy', id: '1')
    end
  end
end
