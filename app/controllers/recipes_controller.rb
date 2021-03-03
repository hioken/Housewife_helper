class RecipesController < ApplicationController
  def top
  end

  def index
    @recipes = Recipe.eager_load(:recipe_ingredients).limit(50)
  end

  def show
    @recipe = Recipe.find(params[:id])
    @recipe_ingredients = @recipe.recipe_ingredients.eager_load(:ingredient)
    @size = params[:size] ? params[:size].to_i : current_end_user.family_size
    @lack_ingredients = FridgeItem.lack_ingredients(current_end_user, @recipe_ingredients, size: @size, ingredient_load: false)
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
