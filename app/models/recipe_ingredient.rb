class RecipeIngredient < ApplicationRecord
  # Setting
  belongs_to :recipe
  belongs_to :ingredient
  
  enum seasoning_unit: [:小さじ, :大さじ, :ml, :g, :つまみ, :少々, :適量]
  
  # Methods
  def self.lack_ingredients(user, recipe_ingredients)
    recipe_ingredients_copy = recipe_ingredients.map {|data| data[0..2] }
    ingredient_names = recipe_ingredients_copy.map { |name, amount, unit| name }
    fridge_items = user.fridge_items.joins(:ingredient).where('ingredients.name': ingredient_names).pluck('ingredients.name', :amount).to_h
    recipe_ingredients_copy.each { |data| data[1] -= fridge_items[data[0]] if fridge_items[data[0]] }.select { |data| data[1] > 0 }
  end
  
end
