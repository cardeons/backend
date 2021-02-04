# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CentercardsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/centercards').to route_to('centercards#index')
    end

    it 'routes to #new' do
      expect(get: '/centercards/new').to route_to('centercards#new')
    end

    it 'routes to #show' do
      expect(get: '/centercards/1').to route_to('centercards#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/centercards/1/edit').to route_to('centercards#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/centercards').to route_to('centercards#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/centercards/1').to route_to('centercards#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/centercards/1').to route_to('centercards#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/centercards/1').to route_to('centercards#destroy', id: '1')
    end
  end
end
