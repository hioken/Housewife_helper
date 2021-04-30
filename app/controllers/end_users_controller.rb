class EndUsersController < ApplicationController
  def show
    unknown_exception_rescue do
      # ユーザーの冷蔵庫の情報を配列で取得、SQLを減らすために一括受取
      foods = current_end_user.fridge_data(false)
      # ジャンル別に分割
      @meats_fishes = []
      @vegetables = []
      @others = []
      @seasonings = [] 
      scope = ApplicationRecord::GENRE_SCOPE
      foods.each do |food|
        if scope[:grain_seasoning].include?(food[0]) #food[0] > 4999 or food[0] < 100
          @seasonings << food
        elsif scope[:other].include?(food[0]) # food[0] > 2999
          @others << food
        elsif scope[:vegetable].include?(food[0]) # food[0] > 999
          @vegetables << food
        elsif scope[:meat_fish].include?(food[0]) # food[0] > 99
          @meats_fishes << food
        else
          Ingredient.exception_ingredient(FridgeItem, food[0])
        end
      end
    end
  end
  
  def shopping_list
    retry_cnt = 0
    unknown_exception_rescue do
      @lack_ingredients = current_end_user.lack_list
      @lack_ingredients.each { |data| data[1] += (4 - data[1] % 4) if data[1] % 4 != 0 } # 1/4個など、数量に端数が出ないよう調整
      @fridge_item = FridgeItem.new
    end
  end
  
  def update
    active_record_exception_rescue(ERROR_MESSAGE[:end_user_update], 'layouts/exception.js.erb') do
      current_end_user.update!(end_user_params)
    end
  end
  
  private
    def end_user_params
      params.require(:end_user).permit(:family_size, :cooking_time_limit)
    end
end
  
  
