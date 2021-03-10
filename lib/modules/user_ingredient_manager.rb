module UserIngredientManager
  def manage(ingredients, end_user_id, mode: :add)
    raise unless ingredients.class == Hash && end_user_id
    if mode == :add
      existings = self.where(end_user_id: end_user_id, ingredient_id: ingredients.keys)
      existings.each do |existing|
        existing.update(amount: (existing.amount + ingredients[existing.ingredient_id]))
        ingredients.delete(existing.ingredient_id)
      end
      
      ingredients.each do |id, amount|
        next unless self::GENRE_SCOPE[:semi_all].include?(id)
        self.new(end_user_id: end_user_id, ingredient_id: id, amount: amount).save
      end
    end
    
    if mode == :cut
      ingredients.delete_if{ |key, value| self::GENRE_SCOPE[:grain_seasoning].include?(key) } if self == FridgeItem
      existings = self.where(end_user_id: end_user_id, ingredient_id: ingredients.keys)
      delete_ids = []
      existings.each do |existing|
        existing.amount -= ingredients[existing.ingredient_id]
        existing.amount <= 0 ? delete_ids << existing.id : existing.save
      end
      self.where(id: delete_ids).delete_all
    end
  end
end
