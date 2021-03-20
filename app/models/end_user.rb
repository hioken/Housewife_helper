class EndUser < ApplicationRecord
  # setting
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :fridge_items, dependent: :destroy
  has_many :user_menus, dependent: :destroy
  has_many :need_ingredients, dependent: :destroy
  
  # Methods
	def pick(genre_scope, *columns)
		constraint = {end_user_id: self.id}
		constraint[:ingredient_id] = self.class::GENRE_SCOPE[genre_scope] if self.class::GENRE_SCOPE[genre_scope]
		self.fridge_items.joins(:ingredient).where(constraint).pluck(*columns)
	end
end
