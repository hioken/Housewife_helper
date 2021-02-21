module IngredientDataGiber
	# CONSTANTs
	GENRE_SCOPE = {
		all: 100..6999,
		meat: 100..499, fish: 500..999, meat_fish: 100..999,
		vegetable: 1000..2999,
		fluit: 3000..3499, fungi: 3500..3999, herb: 4000..4999, other: 3000..4999,
		grain: 5000..5499, seasoning: 5500..6999, grain_seasoning: 5000..6999
	}
	
	# Methods
	def pick(genre_scope, *columns)
		table = 
			if self.is_a?(EndUser)
				constraint = {end_user_id: self.id}
				FridgeItem
			else
				raise RunTimeError, 'moduleが無効なモデルにincludeされています、モジュールの定義を確認してください'
			end
		constraint[:ingredient_id] = GENRE_SCOPE[genre_scope] if GENRE_SCOPE[genre_scope]
		table.joins(:ingredient).where(constraint).pluck(*columns)
	end
end

			#elsif self.is_a?(Recipe)
			#	constraint = {recipe_id: self.id}
			#	:recipe_ingredients