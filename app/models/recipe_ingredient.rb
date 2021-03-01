class RecipeIngredient < ApplicationRecord
  # Setting
  belongs_to :recipe
  belongs_to :ingredient
  
  enum mark: ['★', '⓵', '⓶']
  enum seasoning_unit: [:小さじ, :大さじ, :ml, :g, :つまみ, :少々, :適量]
  
  # Methods
  def self.lack_ingredients(user, ingredients)
    names = ingredients.map { |name, amount, unit| name }
    fridge_items = user.fridge_items.joins(:ingredient).where('ingredients.name': names).pluck('ingredients.name', :amount).to_h
    ingredients.each { |data| data[1] -= fridge_items[data[0]] if fridge_items[data[0]] }.delete_if { |data| data[1] < 1 }
  end
  
end
