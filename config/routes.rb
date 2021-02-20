Rails.application.routes.draw do
  resource :end_users, only: [:show, :update]
  resources :fridge_items, only: [:new, :create, :update]
  
  devise_for :end_users, skip: :password
  root 'end_users#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
