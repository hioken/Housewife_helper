class UserMenusController < ApplicationController
	def index
		@user_menus = current_end_user.user_menus.eager_load(:recipe)
		@lacks = FridgeItem.lack_ingredients(current_end_user, current_end_user.need_ingredients)
	end
	
	def create
		user_menu = current_end_user.user_menus.new(user_menu_params)
		recipe = Recipe.find(user_menu.recipe_id)
		if duplicate = UserMenu.find_by(end_user_id: user_menu.end_user_id, cooking_date: user_menu.cooking_date)
			destroy_ingredients = duplicate.recipe.recipe_ingredients.pluck(:ingredient_id, :amount).delete_if{ |data| data[1] *= duplicate.sarve; !(NeedIngredient::GENRE_SCOPE[:semi_all].include?(data[0])) }.to_h
			NeedIngredient.manage(destroy_ingredients, user_menu.end_user_id, mode: :cut)
			duplicate.destroy
		end
		user_menu.save
		needs = {}
		recipe.recipe_ingredients.each do |ingredient|
			needs[ingredient.ingredient_id] = ingredient.amount * user_menu.sarve
		end
		NeedIngredient.manage(needs, user_menu.end_user_id, mode: :add)
		redirect_to root_path
	end
	
	def update
		user_menu = UserMenu.find(params[:id])
		if user_menu.sarve != params[:user_menu][:sarve].to_i
			old_sarve = user_menu.sarve
			user_menu.update(user_menu_params)
			mode = (old_sarve > user_menu.sarve ? :cut : :add)
			remainder = (old_sarve - user_menu.sarve).abs
			ingredients = {}
			user_menu.recipe.recipe_ingredients.each { |data| ingredients[data.ingredient_id] = data.amount * remainder }
			NeedIngredient.manage(ingredients, current_end_user.id, mode: mode)
		end
			redirect_to user_menus_path
	end
	
	def destroy
		user_menu = UserMenu.find(params[:id])
		ingredients = {}
		user_menu.recipe.recipe_ingredients.each { |data| ingredients[data.ingredient_id] = data.amount * user_menu.sarve }
		NeedIngredient.manage(ingredients, current_end_user.id, mode: :cut)
		user_menu.destroy
		redirect_to user_menus_path
	end
	
	private
		def user_menu_params
      params.require(:user_menu).permit(:cooking_date, :sarve, :recipe_id)
    end
end