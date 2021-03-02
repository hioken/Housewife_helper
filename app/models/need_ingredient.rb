class NeedIngredient < ApplicationRecord
  belongs_to :end_user
  belongs_to :ingredient_id
end
