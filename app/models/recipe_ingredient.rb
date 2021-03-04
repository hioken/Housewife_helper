class RecipeIngredient < ApplicationRecord
  # Setting
  belongs_to :recipe
  belongs_to :ingredient
  
  enum mark: ['★', '⓵', '⓶']
  enum seasoning_unit: [:小さじ, :大さじ, :ml, :g, :つまみ, :少々, :適量]
  
  # Methods
end
