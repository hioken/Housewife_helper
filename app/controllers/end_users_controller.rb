class EndUsersController < ApplicationController
  before_action :authenticate_end_user!
  def show
    @meats_fishes = current_end_user.fridge_items.joins(:ingredient).where(ingredient_id: 100..999).pluck(:name, :amount, :html_color)
    @vegetables = current_end_user.fridge_items.joins(:ingredient).where(ingredient_id: 1000..2999).pluck(:name, :amount, :html_color)
    @others = current_end_user.fridge_items.joins(:ingredient).where(ingredient_id: 2999..4999).pluck(:name, :amount, :html_color)
    @seasonings = current_end_user.fridge_items.joins(:ingredient).where(ingredient_id: 5000..7999).pluck(:name, :amount, :html_color)
  end
  
  def update
    current_end_user.update(end_user_params)
  end
  
  private
    def end_user_params
      params.require(:end_user).permit(:famiry_size, :cooking_time_limit)
    end
end
