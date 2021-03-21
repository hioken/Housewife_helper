class UserMenu < ApplicationRecord
  #Setting
  belongs_to :end_user
  belongs_to :recipe
  
  validate :cooking_date_check
  attr_accessor :user_id
  
  #Methods
  def menu_ingredients(sarve = self.sarve)
		ingredients = {}
		self.recipe.recipe_ingredients.where(ingredient_id: self.class::GENRE_SCOPE[:semi_all]).each { |data| ingredients[data.ingredient_id] = data.amount * sarve }
		ingredients
  end
  
  private
    def cooking_date_check
      errors.add(:cooking_date, '昨日以降の日付は登録出来ません') if cooking_date < Date.today
    end
end
