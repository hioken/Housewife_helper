class EndUsersController < ApplicationController
  def show
    exception_redirect do
      # ユーザーの冷蔵庫の情報を配列で取得、SQLを減らすために一括受取
      foods = current_end_user.pick(false, :ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id')  # fridge_items.joins(:ingredient).pluck(:ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id')
      p foods
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
    exception_redirect do
      @lack_ingredients = current_end_user.lack_list
      @lack_ingredients.each { |data| data[1] += (4 - data[1] % 4) if data[1] % 4 != 0 } # 1/4個など、数量に端数が出ないよう調整
      @fridge_item = FridgeItem.new
    end
  end
  
  def update
    retry_cnt = 0
    begin
      current_end_user.update!(end_user_params)
    rescue ActiveRecord::RecordInvalid => e
      e.exception_log
      set_rescue_variable(ERROR_MESSAGE[:end_user_update])
      render 'layouts/exception.js.erb'
    rescue => e
      retry_cnt += 1
      retry if retry_cnt <= RETRY_COUNT
      e.exception_log
      redirect_to exceptions_path
    end
  end
  
  private
    def end_user_params
      params.require(:end_user).permit(:family_size, :cooking_time_limit)
    end
end
  
  
