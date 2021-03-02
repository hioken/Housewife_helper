Rails.application.routes.draw do
  root 'recipes#top'
  resources :recipes, except: [:destroy]
  resource :end_users, only: [:show, :update]
  resources :fridge_items, only: [:new, :create, :update]
  resources :user_menus, except: [:show, :edit]
  
  devise_for :end_users, skip: :password
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
