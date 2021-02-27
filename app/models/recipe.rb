class Recipe < ApplicationRecord
  # Setting
  has_many :recipe_ingredients
  
  # Methods
  def how_mach_already(user)
    recipe_ingredients = self.recipe_ingredients.where(ingredient_id: GENRE_SCOPE[:not_seasoning]).pluck(:ingredient_id, :amount).to_h
    ingredient_ids = recipe_ingredients.map { |key, value| key }
    fridge_items = user.fridge_items.where(ingredient_id: ingredient_ids).pluck(:ingredient_id, :amount).to_h
    cover = 0
    fridge_items.merge(recipe_ingredients) { |id, amount_1, amount_2| amount_1 - amount_2}.each { |key, amount| cover += 1 if amount > 0 && amount != recipe_ingredients[key] } if fridge_items
    ret = (cover * 100 / ingredient_ids.size)
    ret > 40 ? ret : nil
  end
  
end
