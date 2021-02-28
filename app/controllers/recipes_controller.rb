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
    @lack_ingredients = RecipeIngredient.lack_ingredients(current_end_user, @recipe_ingredients)
    @recipe_ingredients.each do |data|
      if data[3] != 'option'
        data[1] = data[1] * @size / 4
      else
        data[1] /= 4
        # ここメソッドにしてどっかにおく
        if > 200
          data[1] -= 200
          data[2] = 'ml'
        else
          data
        end
        data[1] *= @size
          
        
      end
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
