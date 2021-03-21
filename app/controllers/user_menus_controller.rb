class UserMenusController < ApplicationController
	def index
		@user_menus = current_end_user.user_menus.eager_load(:recipe).where(is_cooked: false)
		@lacks = FridgeItem.lack_ingredients(current_end_user, current_end_user.need_ingredients, ingredient_load: true)
	end
	
	def new
		@sarve = params[:sarve] ? params[:sarve].to_i : current_end_user.family_size
		@recipes = recommend(4, @sarve) # レシピデータを取得
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
			RecipeIngredient.where(recipe_id: params[:id].to_i).each { |ingre| lacks_tmp[ingre.ingredient.id] -= ingre.amount * params[:old_sarve].to_i }
			@recipe[0].recipe_ingredients.each { |ingre| lacks_tmp[ingre.ingredient.id] = lacks_tmp[ingre.ingredient.id].to_i + ingre.amount * sarve }
			@lacks = FridgeItem.lack_ingredients(current_end_user, lacks_tmp)
			
			#次のflashのセット
			flash[:lacks] = lacks_tmp
			flash[:recipes] = ids << new_id
		else
			days = params[:days] ? params[:days].to_i : 7
			@recipes = recommend(days, current_end_user.family_size, type: :recipe_only).map { |recipe| [recipe, current_end_user.family_size] }
			if (week_menu = current_end_user.user_menus.where(cooking_date: (@set_today)..(@set_today + days - 1))).size > 0
				week_menu.each do |menu|
					@recipes.insert((menu.cooking_date - @set_today).to_i, [menu.recipe, menu.sarve])
				end
				@recipes.slice!(-(week_menu.size)..-1)
			end
			recipes_h = @recipes.map{|recipe, sarve| [recipe.id, sarve]}.to_h
			lacks_tmp = multiple_recipe_ingredients(recipes_h)
			@lacks = FridgeItem.lack_ingredients(current_end_user, lacks_tmp)
			flash[:lacks] = lacks_tmp
			flash[:recipes] = recipes_h.keys
		end
	end
	
	def create
		before = Rails.application.routes.recognize_path(request.referrer)[:action]
		if before == "new_week"
			# paramsから{recipe_id => sarve}を作成
			recipes_h = {}
			params[:user_menus].each { |key, values| recipes_h[values[:recipe_id].to_i] = values[:sarve].to_i }
			
			# 新しいuser_menuのインスタンスを作成 && その必要材料をまとめる
			today = @set_today
			user_menus = []
			recipes_h.keys.each_with_index {|id, i| user_menus << current_end_user.user_menus.new(recipe_id: id, cooking_date: today + i, sarve: recipes_h[id]) }
			need_ingredients = multiple_recipe_ingredients(recipes_h)
			
			# 新しいuser_menuを保存する際に、日付が被ってしまうuser_menuを取得
			duplicates = current_end_user.user_menus.where(cooking_date: today..(today + recipes_h.size - 1))
			duplicates_h = {}
			duplicates.each { |duplicate| duplicates_h[duplicate.recipe.id] = duplicate.sarve } if duplicates
			destroy_ingredients = multiple_recipe_ingredients(duplicates_h)
			
			# 被るuser_menuを削除、新しいuser_menuを保存、削除更新した分の材料をNeedIngredientに反映
			if duplicates
				duplicates.delete_all
				raise 'user_menus delete_all error' if duplicates.size > 0
			end
			user_menus.each { |user_menu| user_menu.save }
			NeedIngredient.manage(destroy_ingredients, current_end_user.id, mode: :cut) if destroy_ingredients
			NeedIngredient.manage(need_ingredients, current_end_user.id, mode: :add) if need_ingredients
			redirect_to user_menus_path
		else
			# 新しいuser_menuのインスタンスを作成 && その必要材料をまとめる
			user_menu = current_end_user.user_menus.new(user_menu_params)
			need_ingredients = user_menu.menu_ingredients
			
			# 新しいuser_menuを保存する際に、日付が被ってしまうuser_menuを取得 && その必要材料をまとめる
		  duplicate = current_end_user.user_menus.find_by(cooking_date: user_menu.cooking_date)
			destroy_ingredients = duplicate.menu_ingredients if duplicate
			
			# 被るuser_menuを削除、新しいuser_menuを保存、削除更新した分の材料をNeedIngredientに反映
			user_menu.user_id = current_end_user.id
			if user_menu.save
				duplicate.destroy! if duplicate
				NeedIngredient.manage(destroy_ingredients, current_end_user.id, mode: :cut) if destroy_ingredients
				NeedIngredient.manage(need_ingredients, current_end_user.id, mode: :add) if need_ingredients
				redirect_to user_menus_path
			else
    		@recipe = Recipe.find(params[:user_menu][:recipe_id])
    		@recipe_ingredients = @recipe.recipe_ingredients.eager_load(:ingredient)
    		@size = params[:size] ? params[:size].to_i : current_end_user.family_size
    		@lack_ingredients = FridgeItem.lack_ingredients(current_end_user, @recipe_ingredients, size: @size, ingredient_load: false)
				@todays_menu = current_end_user.user_menus.find_by(cooking_date: @set_today, is_cooked: false)
				@yesterday = true
				render 'recipes/show'
			end
		end
	end
	
	def update
		user_menu = UserMenu.find(params[:id])
		if user_menu.sarve != params[:user_menu][:sarve].to_i
			# アップデートする前に古い人数を取得
			old_sarve = user_menu.sarve
			# アップデート
			user_menu.update!(user_menu_params)
			
			# メニューの新旧の人数を比較
			## 増: needを追加 / 減: needを減らす
			mode = (old_sarve > user_menu.sarve ? :cut : :add)
			remainder = (old_sarve - user_menu.sarve).abs
			ingredients = user_menu.menu_ingredients(remainder)
			NeedIngredient.manage(ingredients, current_end_user.id, mode: mode)
		end
			redirect_to user_menus_path
	end
	
	def destroy
		user_menu = UserMenu.find(params[:id])
		ingredients = user_menu.menu_ingredients
		NeedIngredient.manage(ingredients, current_end_user.id, mode: :cut)
		user_menu.destroy
		redirect_to user_menus_path
	end

	def cooked
		if params[:announce] #アナウンス機能の処理
			# 削除するidと
			destroy_ids = []; cooked_ids = []
			destroy_h = {}; recipe_h = {}
			d_ingredients = {}; c_ingredients = {}
			params[:announce].each { |id, action| (action == '1' ? cooked_ids : destroy_ids) << id.to_i }
			
			if destroy_ids.size > 0
				destroy_u_ms = current_end_user.user_menus.where(id: destroy_ids)
				destroy_u_ms.each { |user_menu| destroy_h[user_menu.recipe.id] = user_menu.sarve }
				destroy_u_ms.delete_all
				d_ingredients = multiple_recipe_ingredients(destroy_h)
			end
			
			if cooked_ids.size > 0
				cooked_u_ms = current_end_user.user_menus.eager_load(:recipe).where(id: cooked_ids)
				cooked_u_ms.each do |user_menu| 
					recipe_h[user_menu.recipe.id] = user_menu.sarve
					user_menu.update(is_cooked: true) 
				end
				c_ingredients = multiple_recipe_ingredients(recipe_h)
			end
			
			d_ingredients.merge!(c_ingredients) { |id, a_1, a_2| a_1 + a_2 }
			NeedIngredient.manage(d_ingredients, current_end_user.id, mode: :cut) if d_ingredients.size > 0
			FridgeItem.manage(c_ingredients, current_end_user.id, mode: :cut) if c_ingredients.size > 0
			
		else #user_menusからの処理
			# 献立の取得と、manageの引数を作成
			user_menu = UserMenu.find(params[:id])
			ingredients = user_menu.menu_ingredients
			
			# 献立を調理済みに更新
			user_menu.update(is_cooked: true)
			
			# 食材をmanage(mode: :cut)で、必要リストと冷蔵庫から削除
			NeedIngredient.manage(ingredients, current_end_user.id, mode: :cut)
			FridgeItem.manage(ingredients, current_end_user.id, mode: :cut)
		end
		redirect_back fallback_location: end_users_path
	end

	private
		def user_menu_params
      params.require(:user_menu).permit(:cooking_date, :sarve, :recipe_id)
    end
    
    def recommend(quantity = 4, sarve = 1, limit: 50, type: :with_rate, duplicate: true, follow_fridge: true)
			# レシピデータ、冷蔵庫、今週の献立を取得
			recipes = Recipe.eager_load(:recipe_ingredients).limit(limit).where('cooking_time <= ?', current_end_user.cooking_time_limit)
			fridge = current_end_user.fridge_items.where(ingredient_id: FridgeItem::GENRE_SCOPE[:not_seasoning]).pluck(:ingredient_id, :amount).to_h
			week_menu = current_end_user.user_menus.where(cooking_date: (@set_today)..(@set_today + 6)).pluck(:recipe_id) # 今週のレシピを取得
			ids = recipes.pluck(:id).uniq #冷蔵庫で賄えるレシピの数が、指定の数足りなかった時のランダム取得用のid
			
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
    		if !(follow_fridge) # fllow_fridgeがfalseの時は、冷蔵庫の中身をカバーできる事を考慮しない
    			cover_how[recipe.id] = how
    		elsif duplicate && how >= 40 # 40%以上冷蔵庫で賄えるレシピをハッシュに入れる
					cover_how[recipe.id] = how
				elsif how >= 60 # duplicateがfalseの時は、60%以上を賄えるメニューが見つかるたび、冷蔵庫の中身を減らす
					cover_how[recipe.id] = how 
					ingredients.each { |id, amount| fridge[id] -= amount if fridge[id] } 
				end
			end
			
			# 上の処理で残ったレシピが4つになるように調整
    	if !(follow_fridge)
    		selects = ids.sample(quantity)
				cover_how.select!{ |id, how| selects.include?(id) }
    	else
				cover_how = (cover_how.sort_by { |k, v| v }.reverse)[0..(quantity - 1)].to_h
				if cover_how.size < quantity
					record_cnt = Recipe.count
					stop_cnt = 0
					while (cover_how.size < quantity && ids.size > 0)
						id = ids.sample
						ids.delete(id)
						cover_how[id] = 0 if !(cover_how.key?(id)) || (stop_cnt += 1) > 20
					end
					while (cover_how.size < quantity)
						ids = Recipe.limit(10).pluck(:id)
						id = ids.sample
						cover_how[]
					end
				end
			end
			
			# typeが、relationの場合はレシピデータをRelationで返す、arrayの場合はソートした配列で返す、with_rateの場合は賄えている割合付きの２次元配列返す
			if type == :relation
				Recipe.where(id: cover_how.keys)
			elsif type == :recipe_only
				Recipe.where(id: cover_how.keys).sort_by{|recipe| cover_how[recipe.id] }.reverse
			elsif type == :with_rate
				Recipe.where(id: cover_how.keys).sort_by{|recipe| cover_how[recipe.id] }.reverse.map { |recipe| [recipe, cover_how[recipe.id]] } 
			else
				raise '戻り値を正しく選択してください(引数type: )'
			end
    end
    
    def multiple_recipe_ingredients(recipes_h)
			ret = {}
			RecipeIngredient.where(recipe_id: recipes_h.keys).each do |ingre|
				next unless RecipeIngredient::GENRE_SCOPE[:semi_all].include?(ingre.ingredient_id)
				if ret[ingre.ingredient_id]
					ret[ingre.ingredient_id] += ingre.amount * recipes_h[ingre.recipe_id]
				else
					ret[ingre.ingredient_id] = ingre.amount * recipes_h[ingre.recipe_id]
				end
			end
			ret
    end
end