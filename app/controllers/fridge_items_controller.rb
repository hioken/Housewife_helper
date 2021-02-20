class FridgeItemsController < ApplicationController
  def new
  end
  
  def create
  end
  
  def update
    @fridge_item = FridgeItem.find(params[:id])
    @fridge_item.update(fridge_item_params)
  end
  
  private
    def fridge_item_params
      params.require(:fridge_item).permit(:amount)
    end
end
