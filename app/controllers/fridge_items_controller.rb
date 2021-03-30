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
    if params[:from] == 'single' # 買い物リストからの処理
      ingredient_data = {params[:ingredient_id].to_i => params[:amount].to_i}
      @delete_html = params[:ingredient_id]
    else # 冷蔵庫追加画面からの処理
      params[:fridge_items].each do |key, values|
        next if (values[:id_unit] == '' or values[:amount] == '')
        id_unit = values[:id_unit].split(',')
        ingre_id = id_unit[0].to_i
        # amountをルール通り4倍する、理由は設計書のER図の説明欄
        amount = values[:amount].to_i * 4
        amount *= 100 if id_unit[1] == 'g'
        if ingredient_data[ingre_id]
          ingredient_data[ingre_id] += amount unless ingredient_data[ingre_id] == ApplicationRecord::BOOLEAN_AMOUNT
        else
          ingredient_data[ingre_id] = amount
        end
      end
      redirect_to end_users_path
    end
    current_end_user.manage(ingredient_data, mode: :add)
  end

  def update
    @fridge_item = FridgeItem.find(params[:id])
    if params[:fridge_item][:amount] != "0" # 更新対象が0にならなければ(まだ冷蔵庫に対象が残っていれば)、そのまま更新
      begin
        @fridge_item.update!(fridge_item_params)
      rescue => e
      end
    else # 更新対象が0になった場合、削除して、対象があった列のhtmlをまるまる更新
      destroied_id = @fridge_item.ingredient_id
      columns = [:ingredient_id, :name, :amount, :unit, :html_color, 'fridge_items.id']
      @fridge_item.destroy
      if destroied_id > 4999 or destroied_id < 100
        @foods = current_end_user.pick(:grain_seasoning, *columns)
        @food_box_id = 'seasonings'
        @food_genre = '調味料/穀物'
      elsif destroied_id > 2999
        @foods = current_end_user.pick(:other, *columns)
        @food_box_id = 'others'
        @food_genre = 'その他' 
      elsif destroied_id > 999
        @foods = current_end_user.pick(:vegetable, *columns)
        @food_box_id = 'vegetables'
        @food_genre = '野菜'
      elsif destroied_id > 99
        @foods = current_end_user.pick(:meat_fish, *columns)
        @food_box_id = 'meats_fishes'
        @food_genre = '肉/魚'
      else
        raise "想定されていない食材コードです|| destroied_id: #{destroied_id}, controller: fridge_items_controller"
      end
      render :destroy
    end
  end

  private
    def fridge_item_params
      params.require(:fridge_item).permit(:amount)
    end
end