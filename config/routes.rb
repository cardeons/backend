# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :users
  resources :monsterthrees
  resources :monstertwos
  resources :monsterones
  resources :playercurses
  resources :handcards
  resources :inventories
  resources :ingamedecks
  resources :players
  resources :gameboards
  resources :cards
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :sessions, only: [:create]
  resources :registrations, only: [:create]
  # delete :logout, to: "sessions#logout"
  get :logged_in, to: "application#authorized"
  root 'welcome#index'
end
