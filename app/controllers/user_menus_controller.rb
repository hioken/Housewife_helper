class UserMenusController < ApplicationController
	def index
	end
	
	def create
		user_menu = curret_end_user.user_menus.new(user_menu_params)
		recipe = Recipe.find(user_menu.recipe_id)
		if duplicate = current_end_user.user_menus.find_by(end_user_id: user_menu.end_user_id, cooking_date: user_menu.cooking_date)
			duplicate.destroy
		end
		user_menu.save
		NeedIngredient.manage(recipe.ingredients, user_menu.end_user_id, mode: :add)
	end
	
	private
		def user_menu_params
      params.require(:user_menu).permit(:cooking_date, :sarve, :recipe_id)
    end
end