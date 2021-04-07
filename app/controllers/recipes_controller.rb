class RecipesController < ApplicationController
  def top
  end

  def index
    exception_redirect do
      @recipes = Recipe.all
      @ingredients = {}
      @recipes.each { |recipe| @ingredients[recipe.id] = {}}
      @recipes.joins(:recipe_ingredients).where('recipe_ingredients.ingredient_id': ApplicationRecord::GENRE_SCOPE[:not_seasoning]).pluck(:id, :ingredient_id, :amount).each do |data|
        @ingredients[data[0]][data[1]] = data[2]
      end
      @fridge_items = current_end_user.fridge_items.where(ingredient_id: ApplicationRecord::GENRE_SCOPE[:not_seasoning]).pluck(:ingredient_id, :amount).to_h
    end
  end

  def show
    retry_cnt = 0
    exception_redirect do
      @recipe = Recipe.find(params[:id])
      @recipe_ingredients = @recipe.recipe_ingredients.eager_load(:ingredient)
      @size = params[:size] ? params[:size].to_i : current_end_user.family_size
      @lack_ingredients = current_end_user.lack_list(@recipe_ingredients.map{ |ingre| [ingre.ingredient_id, ingre.amount * @size]}.to_h)
		  @todays_menu = current_end_user.user_menus.find_by(cooking_date: @set_today, is_cooked: false)
    end
  end
  
  def cooked
	  ingredients = Recipe.find(params[:id]).recipe_ingredients_hash(params[:size].to_i)
	  begin
	    FridgeItem.transaction do
	      current_end_user.manage(ingredients, mode: :cut)
	    end
      @lack_ingredients = current_end_user.lack_list(ingredients)
	  rescue => e
	    e.exception_log
	    @exception_message = ERROR_MESSAGE[:user_menu_cooked]
	    render 'layouts/exception'
	  end
  end

  def new
  end

  def create
  end

=begin
  def edit
  end
  
  def update
  end
=end  
end
