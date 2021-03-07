class UserMenusController < ApplicationController
	def index
		@user_menus = current_end_user.user_menus.eager_load(:recipe).where(is_cooked: false)
		@lacks = FridgeItem.lack_ingredients(current_end_user, current_end_user.need_ingredients)
	end
	
	def new
		@sarve = params[:sarve] ? params[:sarve].to_i : current_end_user.family_size
		@recipes = recommend(4, @sarve)
		# レシピデータを取得
	end
	
	def new_week
		if params[:menu_change]
			# 変更前のレシピのsarveを取得
			sarve = params[:sarve].to_i
			
			# 新しいレシピデータの取得
			ids = flash[:recipes].map(&:to_i)
			stop_cnt = 0
			new_id = 
				loop do
					ret = rand(1..Recipe.count)
					break ret if !(ids.include?(ret)) || (stop_cnt += 1) > 20
				end
			@recipe =  [Recipe.find(new_id), sarve]
			
			# lacksの編集
			lacks_tmp = flash[:lacks].map { |id, amount| [id.to_i, amount] }.to_h
			Recipe_ingredient.where(recipe_id: params[:id].to_i).each { |ingredient| lacks_tmp[ingredient.ingredient.id] -= ingredient.amount * sarve }
			@recipe[0].recipe_ingredients.each { |ingredient| lacks_tmp[ingredient.ingredient.id] = lacks_tmp[ingredient.ingredient.id].to_i + ingredient.amount * sarve }
			@lacks = FridgeItem.lack_ingredients(current_end_user, lacks_tmp)
			
			#次のflashのセット
			flash[:lacks] = lacks_tmp
			flash[:recipes] = ids << new_id
		else
			days = params[:days] ? params[:days].to_i : 7
			@recipes = recommend(days, current_end_user.family_size, type: :recipe_only).map { |recipe| [recipe, current_end_user.family_size] }
			if (week_menu = current_end_user.user_menus.where(cooking_date: (Date.today)..(Date.today + days - 1))).size > 0
				week_menu.each do |menu|
					@recipes.insert((menu.cooking_date - Date.today).to_i, [menu.recipe, menu.sarve])
				end
				@recipes.slice!(-(week_menu.size)..-1)
			end
			recipes_h = @recipes.map{|recipe, sarve| [recipe.id, sarve]}.to_h
			lacks_tmp = {}
			RecipeIngredient.where(recipe_id: recipes_h.keys).each do |ingredient|
				next unless RecipeIngredient::GENRE_SCOPE[:semi_all].include?(ingredient.ingredient_id)
				if lacks_tmp[ingredient.ingredient_id]
					lacks_tmp[ingredient.ingredient_id] += ingredient.amount * recipes_h[ingredient.recipe_id]
				else
					lacks_tmp[ingredient.ingredient_id] = ingredient.amount * recipes_h[ingredient.recipe_id]
				end
			end
			@lacks = FridgeItem.lack_ingredients(current_end_user, lacks_tmp)
			flash[:lacks] = lacks_tmp
			flash[:recipes] = recipes_h.keys
		end
	end
	
	def new_week_change
		recipe = Recipe.find(params[:recipe])
		recipe.recipe_ingredients.each do ||
		end
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
    
    def recommend(quantity = 4, sarve = 1, limit: 50, type: :with_rate, duplicate: true, follow_fridge: true)
			# レシピデータ、冷蔵庫、今週の献立を取得
			recipes = Recipe.eager_load(:recipe_ingredients).limit(limit)
			fridge = current_end_user.fridge_items.where(ingredient_id: FridgeItem::GENRE_SCOPE[:not_seasoning]).pluck(:ingredient_id, :amount).to_h
			week_menu = current_end_user.user_menus.where(cooking_date: (Date.today)..(Date.today + 6)).pluck(:recipe_id) # 今週のレシピを取得
			
			# 各レシピの冷蔵庫の中身で賄える量を計算、{reicpe: 割合}でcover_howに格納、40%以下(duplicate falseの場合は60%以下)の割合は0とする
			cover_how = {}
			recipes.each do |recipe|
				next if week_menu.include?(recipe.id) # 今週のレシピに含まれているレシピはスルー
				cover_cnt, ingredient_cnt = 0, 0
				ingredients = recipe.recipe_ingredients.pluck(:ingredient_id, :amount).to_h
				ingredients.each do |id, amount|
					next unless RecipeIngredient::GENRE_SCOPE[:not_seasoning].include?(id) # 調味料は考慮しない
					ingredient_cnt += 1
					cover_cnt += 1 if fridge[id] && fridge[id] - amount * sarve >= 0
				end
    		how = (cover_cnt * 100 / ingredient_cnt)
    		
    		# メニュー候補追加処理
    		if !(follow_fridge)
    			cover_how[recipe.id] = how
    		elsif duplicate && how >= 40 
					cover_how[recipe.id] = how
				elsif how >= 60 # duplicateがfalseの時は、60%以上を賄えるメニューが見つかるたび、冷蔵庫の中身を減らす
					cover_how[recipe.id] = how 
					ingredients.each { |id, amount| fridge[id] -= amount if fridge[id] } 
				end
			end
			
			# 上の処理で残ったレシピが4つになるように調整
    	if !(follow_fridge)
    		selects = (0...recipes.size).to_a.sample(quantity)
				cover_how.select!{ |id, how| selects.include?(id) }
    	else
				cover_how = (cover_how.sort_by { |k, v| v }.reverse)[0..(quantity - 1)].to_h
				if cover_how.size < quantity
					record_cnt = Recipe.count
					stop_cnt = 0
					while (cover_how.size < quantity)
						id = rand(1..record_cnt)
						cover_how[id] = 0 if !(cover_how.key?(id)) || (stop_cnt += 1) > 20
					end
				end
			end
			
			# typeが、relationの場合はレシピデータをRelationで返す、arrayの場合はソートした配列で返す、with_rateの場合は賄えている割合付きの２次元配列返す
			if type == :relation
				Recipe.where(id: cover_how.keys)
			elsif type == :recipe_only
				Recipe.where(id: cover_how.keys).sort_by{|data| cover_how[data.id] }.reverse
			elsif type == :with_rate
				Recipe.where(id: cover_how.keys).sort_by{|data| cover_how[data.id] }.reverse.map { |recipe| [recipe, cover_how[recipe.id]] } 
			else
				raise '戻り値を正しく選択してください(引数type: )'
			end
    end
end