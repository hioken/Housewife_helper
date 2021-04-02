class EndUser < ApplicationRecord
  # setting
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :fridge_items, dependent: :destroy
  has_many :user_menus, dependent: :destroy
  
  with_options presence: true do
  	validates :user_name
  	validates :cooking_time_limit, numericality: {greater_than: 0}
  	validates :family_size, numericality: {greater_than: 0, less_than: 13}
  end
  
  # Methods
	def pick(genre_scope, *columns)
		constraint = {end_user_id: self.id}
		constraint[:ingredient_id] = self.class::GENRE_SCOPE[genre_scope] if self.class::GENRE_SCOPE[genre_scope]
		self.fridge_items.joins(:ingredient).where(constraint).pluck(*columns)
	end
	
	def fridge_hash(arg_ingredients = false)
		ret = self.fridge_items.pluck(:ingredient_id, :amount).to_h
		ret.select{ |id, a| arg_ingredients.include?(id) } if arg_ingredients
  end
	
	def need_ingredients(key: false)
		@set_today = Outline.find_by(user: self.id).today
	  needs = self.user_menus.joins(recipe: :recipe_ingredients).where(cooking_date: @set_today..Float::INFINITY, is_cooked: false, 'recipe_ingredients.ingredient_id': ApplicationRecord::GENRE_SCOPE[:semi_all]).pluck(:ingredient_id, :amount, :sarve)
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
  
	def lack_list(arg_ingredients = false, with_id: true)
		raise 'lack_list(models/end_user.rb)の引数がHash型ではありません' if arg_ingredients && arg_ingredients.class != Hash
	  needs = (arg_ingredients ? arg_ingredients.select { |id, amount| ApplicationRecord::GENRE_SCOPE[:semi_all].include?(id) } : self.need_ingredients)
	  fridge = self.fridge_hash(needs)
	  needs.merge!(fridge) { |id, a_1, a_2| a_1 - a_2 }
	  needs.delete_if { |id, a| a <= 0 }
	  if with_id
	    Ingredient.where(id: needs.keys).map { |ingre| [ingre.name, needs[ingre.id], ingre.unit, ingre.id] }
	  else
	    Ingredient.where(id: needs.keys).map { |ingre| [ingre.name, needs[ingre.id], ingre.unit] }
	  end
	end
	  
  def manage(ingredients, mode: :add)
    raise ArgumentError, "expected Hash, give #{ingredients.class}" if ingredients.class != Hash
    if mode == :add
      existings = self.fridge_items.where(ingredient_id: ingredients.keys)
      existings.each do |existing|
      	if FridgeItem::GENRE_SCOPE[:grain_seasoning].include?(existing.ingredient_id)
      		existing.update!(amount: FridgeItem::BOOLEAN_AMOUNT)
      	else
        	existing.update!(amount: (existing.amount + ingredients[existing.ingredient_id]))
        end
        ingredients.delete(existing.ingredient_id)
      end
      
      ingredients.each do |id, amount|
        next unless FridgeItem::GENRE_SCOPE[:semi_all].include?(id)
      	if FridgeItem::GENRE_SCOPE[:grain_seasoning].include?(id)
        	self.fridge_items.new(ingredient_id: id, amount: FridgeItem::BOOLEAN_AMOUNT).save!
        else
        	self.fridge_items.new(ingredient_id: id, amount: amount).save!
        end
      end
    end
    
    if mode == :cut
    	ingredients.delete_if{ |key, value| FridgeItem::GENRE_SCOPE[:grain_seasoning].include?(key) }
    	existings = self.fridge_items.where(ingredient_id: ingredients.keys)
    	delete_ids = []
    	existings.each do |existing|
    	  existing.amount -= ingredients[existing.ingredient_id]
    	  existing.amount <= 0 ? delete_ids << existing.id : existing.save!
    	end
    	
    	self.fridge_items.where(id: delete_ids).delete_all
    end
  end
end
