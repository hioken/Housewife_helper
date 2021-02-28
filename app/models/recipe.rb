class Recipe < ApplicationRecord
  # Setting
  has_many :recipe_ingredients
  
  # Methods
  def self.lack_ingredients(user, recipe_ingredients)
    recipe_ingredients_copy = recipe_ingredients.map {|data| data[0..2] }
    ingredient_names = recipe_ingredients_copy.map { |name, amount, unit| name }
    fridge_items = user.fridge_items.joins(:ingredient).where('ingredients.name': ingredient_names).pluck('ingredients.name', :amount).to_h
    recipe_ingredients_copy.each { |data| data[1] -= fridge_items[data[0]] if fridge_items[data[0]] }.select { |data| data[1] > 0 }
  end
  
  def how_mach_already(user)
    recipe_ingredients = self.recipe_ingredients.where(ingredient_id: GENRE_SCOPE[:not_seasoning]).pluck(:ingredient_id, :amount).to_h
    ingredient_ids = recipe_ingredients.map { |key, value| key }
    fridge_items = user.fridge_items.where(ingredient_id: ingredient_ids).pluck(:ingredient_id, :amount).to_h
    cover = 0
    recipe_ingredients.merge(fridge_items) { |id, amount_1, amount_2| amount_1 - amount_2}.each { |key, amount| cover += 1 if amount < 0 } if fridge_items.size != 0
    ret = (cover * 100 / ingredient_ids.size)
    ret > 40 ? ret : nil
  end
end
