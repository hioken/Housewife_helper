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
      @fridge_item.destroy
      if code > 4999 or code < 100
        @foods = current_end_user.fridge_items.joins(:ingredient).where(ingredient_id: 5000..9999).pluck(:ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id')
        @food_box_id = 'seasonings'
        @foods_genre = '調味料/穀物'
      elsif code > 2999
        @foods = current_end_user.fridge_items.joins(:ingredient).where(ingredient_id: 2999..4999).pluck(:ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id')
        @food_box_id = 'others'
        @foods_genre = 'その他' 
      elsif code > 999
        @foods = current_end_user.fridge_items.joins(:ingredient).where(ingredient_id: 1000..1999).pluck(:ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id')
        @food_box_id = 'vegetables'
        @foods_genre = '野菜'
      elsif code > 99
        @foods = current_end_user.fridge_items.joins(:ingredient).where(ingredient_id: 100..999).pluck(:ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id')
        @food_box_id = 'meats_fishes'
        @foods_genre = '肉/魚'
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
