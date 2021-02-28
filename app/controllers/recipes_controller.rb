class RecipesController < ApplicationController
  def top
  end

  def index
    @recipes = Recipe.eager_load(:recipe_ingredients).limit(50)
  end

  def show
    @recipe = Recipe.find(params[:id])
    @recipe_ingredients = @recipe.recipe_ingredients.eager_load(:ingredient)
    @size = current_end_user.family_size
    @lack_ingredients = RecipeIngredient.lack_ingredients(current_end_user, @recipe_ingredients.pluck(:name, :amount, :unit).each {|data| data[1] *= @size})
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
