# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :users
  resources :cards
  # resources :users_cards
  get '/users/:id/inventory', to: 'users#show_cards'
  get '/search/:search', to: 'users#search'
  post :inventory, to: 'users_cards#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :sessions, only: [:create]
  resources :registrations, only: [:create]
  get :logged_in, to: 'application#authorized'
  root 'welcome#index'
end
