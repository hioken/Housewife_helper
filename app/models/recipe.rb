class Recipe < ApplicationRecord
  # Setting
  has_many :recipe_ingredients
  has_many :user_menus
  
  # Methods
  def how_mach_already(user)
    recipe_ingredients = self.recipe_ingredients.where(ingredient_id: GENRE_SCOPE[:not_seasoning]).pluck(:ingredient_id, :amount).to_h
    ingredient_ids = recipe_ingredients.map { |key, value| key }
    fridge_items = user.fridge_items.where(ingredient_id: ingredient_ids).pluck(:ingredient_id, :amount)
    fridge_items.select! { |id, amount| amount - recipe_ingredients[id] * user.family_size > 0 }
    ret = (fridge_items.size * 100 / ingredient_ids.size)
    ret > 40 ? ret : nil
  end
end

