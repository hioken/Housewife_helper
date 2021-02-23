module UserIngredientManager
  def manage(ingredients, end_user_id, mode: :add)
    if mode == :add
      ingredients.each do |id, amount|
        next unless self::GENRE_SCOPE[:semi_all].include?(id)
        if existing = self.find_by(end_user_id: end_user_id, ingredient_id: id)
          existing.update(amount: (existing.amount + amount)) unless existing.amount == 9999
        else
          self.new(end_user_id: end_user_id, ingredient_id: id, amount: amount).save
        end
      end
    end
  end
end

# 4の倍数調整