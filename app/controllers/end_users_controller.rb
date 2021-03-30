class EndUsersController < ApplicationController
  def show
    # ユーザーの冷蔵庫の情報を配列で取得、SQLを減らすために一括受取
    foods = current_end_user.pick(false, :ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id')  # fridge_items.joins(:ingredient).pluck(:ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id')
    # ジャンル別に分割
    @meats_fishes = []
    @vegetables = []
    @others = []
    @seasonings = [] 
    foods.each do |food|
      if food[0] > 4999 or food[0] < 100
        @seasonings << food
      elsif food[0] > 2999
        @others << food
      elsif food[0] > 999
        @vegetables << food
      elsif food[0] > 99
        @meats_fishes << food
      else
        raise "想定されていない食材コードです#{code}"
      end
    end
  end
  
  def shopping_list
    @lack_ingredients = current_end_user.lack_list
    @lack_ingredients.each { |data| data[1] += (4 - data[1] % 4) if data[1] % 4 != 0 } # 1/4個など、数量に端数が出ないよう調整
    @fridge_item = FridgeItem.new
  end
  
  def update
    retry_cnt = 0
    begin
      current_end_user.update!(end_user_params)
    rescue => e
      retry_cnt += 1
      retry if retry_cnt <= RETRY_COUNT
      e.exception_log
      render template 'layouts/exception.js.erb'
    end
  end
  
  private
    def end_user_params
      params.require(:end_user).permit(:family_size, :cooking_time_limit)
    end
end
