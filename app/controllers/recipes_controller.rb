class RecipesController < ApplicationController
  def top
  end

  def index
    @recipes = Recipe.eager_load(:recipe_ingredients).limit(50)
  end

  def show
    @recipe = Recipe.find(params[:id])
    @recipe_ingredients = @recipe.recipe_ingredients.joins(:ingredient).pluck('ingredients.name', :amount, 'ingredients.unit', :mark)
    @size = current_end_user.family_size
    @recipe_ingredients.each { |data| data[1] *= @size }
    @lack_ingredients = Recipe.lack_ingredients(current_end_user, @recipe_ingredients)
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
