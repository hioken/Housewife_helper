Rails.application.routes.draw do
  root 'outlines#show'
  resource :outlines, only: [:show, :edit, :update]
  resource :exceptions, only: :show
  
  get 'shopping_list', to: 'end_users#shopping_list', as: :shopping_list
  resource :end_users, only: [:show, :update]
  resources :fridge_items, only: [:new, :create, :update]
  
  # resources :recipes, except: [:destroy]
  get 'top', to: 'recipes#top', as: :top
  
  patch 'recipes/:id/cooked', to: 'recipes#cooked', as: :cooked_recipe
  resources :recipes, except: [:destroy, :edit, :update, :new, :create]
  
  patch 'user_menu/:id/cooked', to: 'user_menus#cooked', as: :cooked_user_menu
  get 'user_menus/new_week', to: 'user_menus#new_week', as: :new_week_user_menu
  resources :user_menus, except: [:show, :edit]
  
  devise_for :end_users, skip: :password
  # resource :ingredients, only: [:new, :create]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
