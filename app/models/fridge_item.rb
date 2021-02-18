class FridgeItem < ApplicationRecord
  # assciation
  belongs_to :end_user
  belongs_to :ingredient
end
