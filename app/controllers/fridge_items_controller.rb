class FridgeItemsController < ApplicationController
  def new
  end

  def create
  end

  def update
    @fridge_item = FridgeItem.find(params[:id])
    if params[:fridge_item][:amount] != "0" 
      @fridge_item.update(fridge_item_params)
    else
      code = @fridge_item.ingredient_id
      columns = [:id, :name, :amount, :unit, :html_color, 'fridge_items.id']
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