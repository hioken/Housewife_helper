class FridgeItemsController < ApplicationController
  def new
    @meats = Ingredient.genre_scope(:meat)
    @fishes = Ingredient.genre_scope(:fish)
    @vegetables = Ingredient.genre_scope(:vegetable)
    @others = Ingredient.genre_scope(:other)
    @grains_seasonings = Ingredient.genre_scope(:grain_seasoning)
    @amounts = (1..20).to_a
    @haves = [['追加', ApplicationRecord::BOOLEAN_AMOUNT]]
  end

  def create
    ingredient_data = {}
    if params[:from] == 'single'
      ingredient_data = {params[:ingredient_id].to_i => params[:amount].to_i}
      @delete_html = params[:ingredient_id]
    else
      params[:fridge_items].each do |key, values|
        next if (values[:id_unit] == '' or values[:amount] == '')
        id_unit = values[:id_unit].split(',')
        code = id_unit[0].to_i
        amount = values[:amount].to_i * 4
        amount *= 100 if id_unit[1] == 'g'
        if ingredient_data[code]
          ingredient_data[code] += amount unless ingredient_data[code] == ApplicationRecord::BOOLEAN_AMOUNT
        else
          ingredient_data[code] = amount
        end
      end
      redirect_to end_users_path
    end
    current_end_user.manage(ingredient_data, mode: :add)
  end

  def update
    @fridge_item = FridgeItem.find(params[:id])
    if params[:fridge_item][:amount] != "0" 
      @fridge_item.update(fridge_item_params)
    else
      code = @fridge_item.ingredient_id
      columns = [:ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id']
      @fridge_item.destroy
      if code > 4999 or code < 100
        @foods = current_end_user.pick(:grain_seasoning, *columns)
        @food_box_id = 'seasonings'
        @food_genre = '調味料/穀物'
      elsif code > 2999
        @foods = current_end_user.pick(:other, *columns)
        @food_box_id = 'others'
        @food_genre = 'その他' 
      elsif code > 999
        @foods = current_end_user.pick(:vegetable, *columns)
        @food_box_id = 'vegetables'
        @food_genre = '野菜'
      elsif code > 99
        @foods = current_end_user.pick(:meat_fish, *columns)
        @food_box_id = 'meats_fishes'
        @food_genre = '肉/魚'
      else
        raise "想定されていない食材コードです|| code: #{code}, controller: fridge_items_controller"
      end
      render :destroy
    end
  end

  private
    def fridge_item_params
      params.require(:fridge_item).permit(:amount)
    end
end