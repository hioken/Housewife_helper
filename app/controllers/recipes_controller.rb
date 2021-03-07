class RecipesController < ApplicationController
  def top
    p flash[:lacks]
  end

  def index
    @recipes = Recipe.all
    @ingredients = {}
    @recipes.each { |recipe| @ingredients[recipe.id] = {}}
    @recipes.joins(:recipe_ingredients).where('recipe_ingredients.ingredient_id': ApplicationRecord::GENRE_SCOPE[:not_seasoning]).pluck(:id, :ingredient_id, :amount).each do |data|
      @ingredients[data[0]][data[1]] = data[2]
    end
    @fridge_items = current_end_user.fridge_items.where(ingredient_id: ApplicationRecord::GENRE_SCOPE[:not_seasoning]).pluck(:ingredient_id, :amount).to_h
  end

  def show
    @recipe = Recipe.find(params[:id])
    @recipe_ingredients = @recipe.recipe_ingredients.eager_load(:ingredient)
    @size = params[:size] ? params[:size].to_i : current_end_user.family_size
    @lack_ingredients = FridgeItem.lack_ingredients(current_end_user, @recipe_ingredients, size: @size, ingredient_load: false)
		@todays_menu = current_end_user.user_menus.find_by(cooking_date: Date.today, is_cooked: false)
		
		if params[:cooked]
		  ingredients = @recipe_ingredients.pluck(:ingredient_id, :amount).map{ |id, amount| [id, amount * @size] }.to_h
		  FridgeItem.manage(ingredients, current_end_user.id, mode: :cut)
		end
  end

  def new
  end

  def edit
  end
  
  def create
  end
  
  def update
  end
end
