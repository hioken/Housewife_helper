class RecipesController < ApplicationController
  def top
  end

  def index
    @recipes = Recipe.eager_load(:recipe_ingredients).limit(50)
  end

  def show
    @recipes = false
    # recipeの材料の差の計算
    # recipeの材料一覧
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
