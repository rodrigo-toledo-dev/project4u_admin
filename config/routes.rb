require 'project4u_admin/api'
require 'rabl_presenter'
Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root to: 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount Project4uAdmin::API => "/api2"
  namespace :api do
    resources :users, only: :create do
      collection do
        post :sign_in
        post :reset_password
      end
    end
    post 'projects', to: 'projects#index'
  end
end
