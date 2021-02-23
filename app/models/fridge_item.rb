require 'modules/user_ingredient_manager.rb'
class FridgeItem < ApplicationRecord
  # setting
  extend UserIngredientManager
  
  belongs_to :end_user
  belongs_to :ingredient
  
end

