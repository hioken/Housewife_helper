class UserMenusController < ApplicationController
	def index
    retry_cnt = 0
    begin
			@user_menus = current_end_user.user_menus.eager_load(:recipe).where(is_cooked: false)
    rescue => e
      retry_cnt += 1
      retry if retry_cnt <= RETRY_COUNT
      e.exception_log
      redirect_to exceptions_path
    end
    begin
			@lacks = current_end_user.lack_list
		rescue => e
      retry_cnt += 1
      retry if retry_cnt <= RETRY_COUNT
			e.exception_log
			@lacks = [['不足食材リストの取得に失敗しました。']]
		end
	end
	
	def new
    retry_cnt = 0
    begin
			@sarve = params[:sarve] ? params[:sarve].to_i : current_end_user.family_size
			@recipes = recommend(4, @sarve) # レシピデータを取得
    rescue => e
      retry_cnt += 1
      retry if retry_cnt <= RETRY_COUNT
      e.exception_log
      redirect_to exceptions_path
    end
	end
	
	def new_week
    retry_cnt = 0
    begin
    	# if分岐は、画面に表示されているメニューの変更処理
    	# else分岐は、このアクションに初めてアクセスした時の処理
			if params[:menu_change]
				# 変更前のレシピのsarveを取得
				sarve = params[:sarve].to_i
				# 新しいレシピデータの取得
				ids = flash[:recipes].map(&:to_i)
				ids.clear if ids.size >= 32
				new_recipes = Recipe.where('cooking_time <= ? AND id NOT IN (?)', current_end_user.cooking_time_limit, ids)
				new_recipe = (new_recipes.size > 0 ? new_recipes[rand(0..(new_recipes.size - 1))] : Recipe.find(rand(0..10)))
				@recipe =  [new_recipe, sarve]
				
				# lacksの編集
				lacks_tmp = flash[:lacks].map { |id, amount| [id.to_i, amount] }.to_h
				RecipeIngredient.where(recipe_id: params[:id].to_i).each { |ingre| lacks_tmp[ingre.ingredient.id] -= ingre.amount * params[:old_sarve].to_i }
				@recipe[0].recipe_ingredients.each { |ingre| lacks_tmp[ingre.ingredient.id] = lacks_tmp[ingre.ingredient.id].to_i + ingre.amount * sarve }
				@lacks = current_end_user.lack_list(lacks_tmp)
				
			#次のflashのセット
				flash[:lacks] = lacks_tmp
				flash[:recipes] = ids << new_recipe.id
			else
				days = params[:days] ? params[:days].to_i : 7 # パラーメータで献立を提案する日数が指定されていないは7
				@recipes = recommend(days, current_end_user.family_size, type: :recipe_only).map { |recipe| [recipe, current_end_user.family_size] }
			#提案日数の範囲で、すでにユーザが登録している献立を取得
				if (week_menu = current_end_user.user_menus.where(cooking_date: (@set_today)..(@set_today + days - 1))).size > 0
					week_menu.each do |menu|
						@recipes.insert((menu.cooking_date - @set_today).to_i, [menu.recipe, menu.sarve])
					end
					@recipes.slice!(-(week_menu.size)..-1)
				end
				recipes_h = @recipes.map{|recipe, sarve| [recipe.id, sarve]}.to_h
				lacks_tmp = multiple_recipe_ingredients(recipes_h)
				@lacks = current_end_user.lack_list(lacks_tmp)
				flash[:lacks] = lacks_tmp
				flash[:recipes] = recipes_h.keys
			end
    rescue => e
      retry_cnt += 1
      retry if retry_cnt <= RETRY_COUNT
      e.exception_log
      redirect_to exceptions_path
    end
	end
	
	def create
	# if分岐はnew_weekアクションから飛んできた場合
	# elseはそれ以外
		before = Rails.application.routes.recognize_path(request.referrer)[:action]
		if before == "new_week"
			# paramsから{recipe_id => sarve}を作成
			recipes_h = {}
			params[:user_menus].each { |key, values| recipes_h[values[:recipe_id].to_i] = values[:sarve].to_i }
			
			# 新しいuser_menuのインスタンスを作成
			today = @set_today
			user_menus = []
			recipes_h.keys.each_with_index {|id, i| user_menus << current_end_user.user_menus.new(recipe_id: id, cooking_date: today + i, sarve: recipes_h[id]) }
			
			# 新しいuser_menuを保存する際に、日付が被ってしまうuser_menuの日付を取得
			duplicate_days = current_end_user.user_menus.where(cooking_date: today..(today + recipes_h.size - 1)).map { |user_menu| user_menu.cooking_date }
			
			failure_cnt = 0
			user_menus.each do |user_menu|
				begin
				# 日付が被っている献立を消去して、新しい献立を追加
					UserMenu.transaction do
						current_end_user.user_menus.find_by(cooking_date: user_menu.cooking_date).destroy! if duplicate_days.include?(user_menu.cooking_date)
						user_menu.save!
					end
				rescue => e
					e.exception_log if failure_cnt < 3
					failure_cnt	+= 1
				end
			end
			flash[:exception_message] = "#{failure_cnt}件の" + ERROR_MESSAGE[:user_menu_update] if failure_cnt > 0
			redirect_to user_menus_path
		else
			# 新しいuser_menuのインスタンスを作成
			user_menu = current_end_user.user_menus.new(user_menu_params)
			
			# 新しいuser_menuを保存する際に、日付が被ってしまうuser_menuを取得
		  duplicate = current_end_user.user_menus.find_by(cooking_date: user_menu.cooking_date)
			
			# 被るuser_menuを削除、新しいuser_menuを保存
			if user_menu.cooking_date >= @set_today
				begin
					UserMenu.transaction do
						duplicate.destroy! if duplicate
						user_menu.save!
					end
				rescue => e
					e.exception_log
					flash[:exception_message] = ERROR_MESSAGE[:user_menu_update]
					redirect_back(fallback_location: user_menus_path)
				else
					redirect_to user_menus_path
				end
			else # 昨日以前の日付の場合はエラーを返す
    		@recipe = Recipe.find(params[:user_menu][:recipe_id])
    		@recipe_ingredients = @recipe.recipe_ingredients.eager_load(:ingredient)
    		@size = params[:size] ? params[:size].to_i : current_end_user.family_size
    		@lack_ingredients = current_end_user.lack_list(@recipe_ingredients.map {|ingre| [ingre.ingredient_id, ingre.amount * @size] }.to_h)
				@todays_menu = current_end_user.user_menus.find_by(cooking_date: @set_today, is_cooked: false)
				@yesterday = true
				render 'recipes/show'
			end
		end
	end
	
	def update
		begin
			UserMenu.find(params[:id]).update!(user_menu_params)
		rescue => e
			e.exception_log
			flash[:exception_message] = ERROR_MESSAGE[:user_menu_update]
		end
		redirect_to user_menus_path
	end
	
	def destroy
		begin
			UserMenu.find(params[:id]).destroy!
		rescue => e
			e.exception_log
			flash[:exception_message] = ERROR_MESSAGE[:user_menu_update]
		end
		redirect_to user_menus_path
	end

	def cooked
		if params[:announce] #アナウンス機能の処理
			# 取り消しするidと調理済みにするidを分割
			destroy_ids = []; cooked_ids = []
			recipe_h = {}; c_ingredients = {}
			params[:announce].each { |id, action| (action == '1' ? cooked_ids : destroy_ids) << id.to_i }
			
			if destroy_ids.size > 0; current_end_user.user_menus.where(id: destroy_ids).delete_all; end # 取り消しするidの献立を削除
			if cooked_ids.size > 0 # 調理済みにするidの献立の処理
				begin
					UserMenu.transaction do
						cooked_u_ms = current_end_user.user_menus.eager_load(:recipe).where(id: cooked_ids)
						cooked_u_ms.each do |user_menu| 
							recipe_h[user_menu.recipe.id] = user_menu.sarve
							user_menu.update!(is_cooked: true) 
						end
						c_ingredients = multiple_recipe_ingredients(recipe_h)
						current_end_user.manage(c_ingredients, mode: :cut) if c_ingredients.size > 0
					end
				rescue => e
					e.exception_log
					flash[:exception_message] = ERROR_MESSAGE[:user_menu_cooked]
				end
			end
		else #user_menusからの処理
			begin
			# 献立の取得と、manageの引数を作成
				user_menu = UserMenu.find(params[:id])
				ingredients = user_menu.menu_ingredients
				UserMenu.transaction do
					user_menu.update!(is_cooked: true) # 献立を調理済みに更新
					current_end_user.manage(ingredients, mode: :cut) # 食材をmanage(mode: :cut)で、必要リストと冷蔵庫から削除
				end
			rescue Exception => e
				e.exception_log
				flash[:exception_message] = ERROR_MESSAGE[:user_menu_cooked]
			end
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