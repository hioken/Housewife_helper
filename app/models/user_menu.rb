require 'modules/user_ingredient_manager.rb'
class UserMenu < ApplicationRecord
  #Setting
  extend UserIngredientManager
  
  belongs_to :end_user
  belongs_to :recipe
  
  #Methods
end
