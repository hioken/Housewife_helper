require 'modules/user_ingredient_manager.rb'
class FridgeItem < ApplicationRecord
  # setting
  include UserIngredientManager
  
  belongs_to :end_user
  belongs_to :ingredient
  
end

