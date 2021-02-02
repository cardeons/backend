# frozen_string_literal: true

Rails.application.routes.draw do
  resources :graveyards
  resources :interceptcards
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
  resources :users_cards
  get '/users/:id/inventory', to: 'users#show_cards'
  post :inventory, to: 'users_cards#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :sessions, only: [:create]
  resources :registrations, only: [:create]
  # delete :logout, to: "sessions#logout"
  get :logged_in, to: 'application#authorized'
  get '/drawdoorcard', to: 'gamemethods#draw_doorcard'
  get '/drawtreasurecard', to: 'gamemethods#draw_treasurecard'
  get '/drawhandcards/:id/:gameboard_id', to: 'gamemethods#draw_handcards'
  root 'welcome#index'
end
