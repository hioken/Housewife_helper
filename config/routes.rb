Rails.application.routes.draw do
  devise_for :end_users, skip: :password
  
  resource :users, only: [:show, :update]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
