class UserMenusController < ApplicationController
	def index
		@user_menus = current_end_user.user_menus.eager_load(:recipe).where(is_cooked: false)
		@lacks = FridgeItem.lack_ingredients(current_end_user, current_end_user.need_ingredients)
	end
	
	def new
		@recipes = recommend(4)
		# レシピデータを取得
	end
=begin
	処理1
	全てのレシピデータを取得
	処理2
	レシピデータの中から%の多い順に4つ取得して配列に[レシピ, %]
	処理3
	レシピデータが4つに満たない場合は、ランダムで選択、配列の大きさから計算
	
	雑に
=end
	
	def new_week
		
	end
	
	def create
		user_menu = current_end_user.user_menus.new(user_menu_params)
		if duplicate = UserMenu.find_by(end_user_id: user_menu.end_user_id, cooking_date: user_menu.cooking_date)
			destroy_ingredients = duplicate.menu_ingredients(duplicate.sarve)
			NeedIngredient.manage(destroy_ingredients, user_menu.end_user_id, mode: :cut)
			duplicate.destroy
		end
		if user_menu.save
			ingredients = user_menu.menu_ingredients(user_menu.sarve)
			NeedIngredient.manage(ingredients, user_menu.end_user_id, mode: :add)
			redirect_to user_menus_path
		else
			redirect_back fallback_location: end_users_path
		end
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
    
    def recommend(quantity = 4, limit: 50, only_recipe: false)
			# レシピの冷蔵庫の中身で賄える量を計算、40%以上を取得
			recipes = Recipe.eager_load(:recipe_ingredients).limit(limit)
			fridge = current_end_user.fridge_items.where(ingredient_id: FridgeItem::GENRE_SCOPE[:not_seasoning]).pluck(:ingredient_id, :amount).to_h
			cover_how = {}
			recipes.each do |recipe|
				cover_cnt, ingredient_cnt = 0, 0
				recipe.recipe_ingredients.each do |ingredient|
					id = ingredient.ingredient_id
					next unless RecipeIngredient::GENRE_SCOPE[:not_seasoning].include?(id)
					ingredient_cnt += 1
					cover_cnt += 1 if fridge[id] && fridge[id] - ingredient.amount >= 0
				end
    		how = (cover_cnt * 100 / ingredient_cnt)
				cover_how[recipe.id] = how if how >= 40
			end
			
			# 上の処理で残ったレシピが4つになるように調整
			cover_how = (cover_how.sort_by { |k, v| v }.reverse)[0..(quantity - 1)].to_h
			if cover_how.size < quantity
				record_cnt = Recipe.count
				while (cover_how.size < quantity)
					id = rand(1..record_cnt)
					cover_how[id] = 0 unless cover_how.key?(id)
				end
			end
			recipes = Recipe.where(id: cover_how.keys).to_a.sort_by{|data| cover_how[data.id] }.reverse
			recipes.map { |recipe| [recipe, cover_how[recipe.id]] } unless only_recipe
    end
end