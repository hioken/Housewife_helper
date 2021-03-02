class UserMenusController < ApplicationController
	def index
	end
	
	def create
		user_menu = current_end_user.user_menus.new(user_menu_params)
		recipe = Recipe.find(user_menu.recipe_id)
		if duplicate = UserMenu.find_by(end_user_id: user_menu.end_user_id, cooking_date: user_menu.cooking_date)
			duplicate.destroy
			NeedIngredient.manage(recipe.recipe_ingredients, user_menu.end_user_id, mode: :cut)
		end
		user_menu.save
		needs = {}
		recipe.recipe_ingredients.each do |ingredient|
			needs[ingredient.ingredient_id] = ingredient.amount * user_menu.sarve
		end
		NeedIngredient.manage(needs, user_menu.end_user_id, mode: :add)
		redirect_to root_path
	end
	
	private
		def user_menu_params
      params.require(:user_menu).permit(:cooking_date, :sarve, :recipe_id)
    end
end