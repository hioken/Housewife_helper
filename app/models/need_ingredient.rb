require 'modules/user_ingredient_manager.rb'

class NeedIngredient < ApplicationRecord
  # Setting
  extend UserIngredientManager
  
  belongs_to :end_user
  belongs_to :ingredient
end
