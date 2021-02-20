class FridgeItemsController < ApplicationController
  def new
  end
  
  def create
  end
  
  def update
    @fridge_item = FridgeItem.find(params[:id])
    if params[:fridge_item][:amount] != 0 
      @fridge_item.update(fridge_item_params)
    else
      @fridge_item.destroy
      render :destroy
    end
  end
  
  private
    def fridge_item_params
      params.require(:fridge_item).permit(:amount)
    end
end
