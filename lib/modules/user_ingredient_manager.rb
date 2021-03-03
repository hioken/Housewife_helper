module UserIngredientManager
  def manage(ingredients, end_user_id, mode: :add)
    raise unless ingredients && end_user_id
    if mode == :add
      existings = self.where(end_user_id: end_user_id, ingredient_id: ingredients.keys)
      existings.each do |existing|
        existing.update(amount: (existing.amount + ingredients[existing.ingredient_id])) unless self::GENRE_SCOPE[:grain_seasoning].include?(existing.ingredient_id)
        ingredients.delete(existing.ingredient_id)
      end
      
      ingredients.each do |id, amount|
        next unless self::GENRE_SCOPE[:semi_all].include?(id)
        amount = self::BOOLEAN_AMOUNT if self::GENRE_SCOPE[:grain_seasoning].include?(id)
        self.new(end_user_id: end_user_id, ingredient_id: id, amount: amount).save
      end
    end
    
    if mode == :cut
      ingredients.delete_if{ |key, value| self::GENRE_SCOPE[:grain_seasoning].include?(key) }
      existings = self.where(end_user_id: end_user_id, ingredient_id: ingredients.keys)
      existings.each do |existing|
        existing.amount -= ingredients[existing.ingredient_id]
        existing.amount <= 0 ? existing.destroy : existing.save
      end
    end
  end
end

# 4の倍数調整