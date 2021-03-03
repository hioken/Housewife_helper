class NeedIngredientsController < ApplicationController
  def show
    @lack_ingredients = FridgeItem.lack_ingredients(current_end_user, current_end_user.need_ingredients.eager_load(:ingredient), ingredient_load: false)
    @lack_ingredients.each { |data| data[1] += (4 - data[1] % 4) if data[1] % 4 != 0 }
    @fridge_item = FridgeItem.new
  end
end