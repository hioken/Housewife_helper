class UserMenusController < ApplicationController
	def index
		@user_menus = current_end_user.user_menus.eager_load(:recipe).where(is_cooked: false)
		@lacks = FridgeItem.lack_ingredients(current_end_user, current_end_user.need_ingredients)
	end
	
	def new
    @ingredients = {}
    @recipes.each { |recipe| @ingredients[recipe.id] = {}}
    @recipes.joins(:recipe_ingredients).where('recipe_ingredients.ingredient_id': ApplicationRecord::GENRE_SCOPE[:not_seasoning]).pluck(:id, :ingredient_id, :amount).each do |data|
      @ingredients[data[0]][data[1]] = data[2]
    end
    @fridge_items = current_end_user.fridge_items.where(ingredient_id: ApplicationRecord::GENRE_SCOPE[:not_seasoning]).pluck(:ingredient_id, :amount).to_h
	end
	
	def new_week
	end
	
	def create
		user_menu = current_end_user.user_menus.new(user_menu_params)
		if duplicate = UserMenu.find_by(end_user_id: user_menu.end_user_id, cooking_date: user_menu.cooking_date)
			destroy_ingredients = duplicate.menu_ingredients(duplicate.sarve)
			NeedIngredient.manage(destroy_ingredients, user_menu.end_user_id, mode: :cut)
			duplicate.destroy
		end
		user_menu.save
		ingredients = user_menu.menu_ingredients(user_menu.sarve)
		NeedIngredient.manage(ingredients, user_menu.end_user_id, mode: :add)
		redirect_to user_menus_path
	end
	
	def update
		user_menu = UserMenu.find(params[:id])
		if user_menu.sarve != params[:user_menu][:sarve].to_i
			old_sarve = user_menu.sarve
			user_menu.update(user_menu_params)
			mode = (old_sarve > user_menu.sarve ? :cut : :add)
			remainder = (old_sarve - user_menu.sarve).abs
			ingredients = user_menu.menu_ingredients(remainder)
			NeedIngredient.manage(ingredients, current_end_user.id, mode: mode)
		end
			redirect_to user_menus_path
	end
	
	def destroy
		user_menu = UserMenu.find(params[:id])
		ingredients = user_menu.menu_ingredients(user_menu.sarve)
		NeedIngredient.manage(ingredients, current_end_user.id, mode: :cut)
		user_menu.destroy
		redirect_to user_menus_path
	end

	def cooked
		if false # アナウンス
		ingredients = {}
		else
			# 献立の取得と、manageの引数を作成
			user_menu = UserMenu.find(params[:id])
			ingredients = user_menu.menu_ingredients(user_menu.sarve)
			# 食材をmanage(mode: :cut)で、必要リストと冷蔵庫から削除
			NeedIngredient.manage(ingredients, current_end_user.id, mode: :cut)
			FridgeItem.manage(ingredients, current_end_user.id, mode: :cut)
			# 献立を調理済みに更新
			user_menu.update(is_cooked: true)
		end
		redirect_back fallback_location: end_users_path
	end

	private
		def user_menu_params
      params.require(:user_menu).permit(:cooking_date, :sarve, :recipe_id)
    end
end