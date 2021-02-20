class EndUsersController < ApplicationController
  before_action :authenticate_end_user!
  def show
    # ユーザーの冷蔵庫の情報を配列で取得、SQLを減らすために一括受取
    foods = current_end_user.fridge_items.joins(:ingredient).pluck(:ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id')
    # ジャンル別に分割
    @meats_fishes = []
    @vegetables = []
    @others = []
    @seasonings = [] 
    foods.each do |food|
      if food[0] > 4999
        @seasonings << food
      elsif food[0] > 2999
        @others << food
      elsif food[0] > 999
        @vegetables << food
      elsif food[0] > 99
        @meats_fishes << food
      end
    end
  end
  
  def update
    current_end_user.update(end_user_params)
  end
  
  private
    def end_user_params
      params.require(:end_user).permit(:family_size, :cooking_time_limit)
    end
end
