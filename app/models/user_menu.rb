require 'modules/user_ingredient_manager.rb'
class UserMenu < ApplicationRecord
  #Setting
  extend UserIngredientManager
  
  belongs_to :end_user
  belongs_to :recipe
  
  #Methods
  def menu_ingredients(sarve = self.sarve)
		ingredients = {}
		self.recipe.recipe_ingredients.where(ingredient_id: self.class::GENRE_SCOPE[:semi_all]).each { |data| ingredients[data.ingredient_id] = data.amount * sarve }
		ingredients
  end
end
