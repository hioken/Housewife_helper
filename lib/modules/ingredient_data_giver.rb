module RelationIngredientDataGiber
	# Methods
	def pick(genre_scope, *columns)
		table = 
			if self.is_a?(EndUser)
				constraint = {end_user_id: self.id}
				FridgeItem
			else
				raise RunTimeError, 'moduleが無効なモデルにincludeされています、モジュールの定義を確認してください'
			end
		constraint[:ingredient_id] = self.class::GENRE_SCOPE[genre_scope] if self.class::GENRE_SCOPE[genre_scope]
		table.joins(:ingredient).where(constraint).pluck(*columns)
	end
end

			#elsif self.is_a?(Recipe)
			#	constraint = {recipe_id: self.id}
			#	:recipe_ingredients