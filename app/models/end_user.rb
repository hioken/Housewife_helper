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
	
	def find_need_ingredients(key: false)
	  needs = self.user_menus.joins(recipe: :recipe_ingredients).where(is_cooked: false).pluck(:ingredient_id, :amount, :sarve)
	  ingredient_ids = []
	  needs.map! do |id, amount, sarve|
	    ingredient_ids << id
	    [id, amount * sarve]
	  end
	  return_list = {}
	  
	  if key == :name
	    name_list = Ingredient.where(id: ingredient_ids).pluck(:id, :name).to_h
	    needs.each do |need|
	      return_list[name_list[need[0]]] ? return_list[name_list[need[0]]] += need[1] : return_list[name_list[need[0]]] = need[1]
	    end
	  else 
	    needs.each do |need|
	      return_list[need[0]] ? return_list[need[0]] += need[1] : return_list[need[0]] = need[1]
	    end
	  end
	  
	  return_list
	end
	
	def lack_list
	  needs = self.find_need_ingredients
	  fridge = self.fridge_items.pluck(:ingredient_id, :amount).to_h
	  needs.delete_if { |id, a| a <= fridge[id].to_i }
	  needs.merge!(fridge) { |id, a_1, a_2| a_1 - a_2 }
	  Ingredient.where(id: needs.keys).map { |ingre| [ingre.name, needs[ingre.id], unit] }
	end
end
