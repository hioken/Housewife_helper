Rails.application.routes.draw do
  root 'recipes#top'
  resource :outlines, only: [:show, :edit, :update]
  
  get 'shopping_list', to: 'end_users#shopping_list', as: :shopping_list
  resource :end_users, only: [:show, :update]
  resources :fridge_items, only: [:new, :create, :update]
  
  # resources :recipes, except: [:destroy]
  resources :recipes, except: [:destroy, :edit, :update, :new, :create]
  patch 'user_menu/:id/cooked', to: 'user_menus#cooked', as: :cooked_user_menu
  get 'user_menus/new_week', to: 'user_menus#new_week', as: :new_week_user_menu
  resources :user_menus, except: [:show, :edit]
  
  # resource :ingredients, only: [:new, :create]
  devise_for :end_users, skip: :password
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
