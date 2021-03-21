class AmountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.ingredient.unit == 'g'
      record.errors.add(attribute, 'が想定されていない数値です。') if value < 100
    else
      record.errors.add(attribute, 'が想定されていない数値です。') if value < 1
    end
  end
end

class FridgeItem < ApplicationRecord
  # setting
  belongs_to :end_user
  belongs_to :ingredient
  
  validates :amount, amount: true
  # Methods
  
  def self.lack_ingredients(user, ingredients, size: 1, ingredient_load: false)
    # 引数 => user: current_end_user, ingredients: 冷蔵庫と比較したい食材のリレーション, size: ingredientsのamountの量の倍率(人数), ingredient_load: falseならingredientをロードしない 
    # ロードする場合のSQLの発行を抑えるため1行で書いている
    # loadオプションがtrueのならingredientsテーブルをjoinsして配列化、そうでないならそのまま配列化
    if ingredients.class != Hash
      lacks = ingredient_load ? ingredients.joins(:ingredient).pluck(:name, :amount, :unit, :ingredient_id) : ingredients.pluck(:name, :amount, :unit, :ingredient_id)
    else
      lacks = Ingredient.where(id: ingredients.keys).pluck(:name, :unit, :id).map { |data| data.insert(1, ingredients[data[2]]) }
    end
    # 水等の不要な食材をハッシュから削除、サイズオプションの倍率もかける
    lacks.delete_if { |data| data[1] *= size; !(self::GENRE_SCOPE[:semi_all].include?(data[3])) }
    # WHEREのIN句に使う名前を配列化
    ids = lacks.map { |data| data[3] }
    # 冷蔵庫の対象と同じ素材を、名前とamountで取得
    fridge_items = user.fridge_items.where(ingredient_id: ids).pluck(:ingredient_id, :amount).to_h
    lacks.each { |data| data[1] -= fridge_items[data[3]] if fridge_items[data[3]] }.delete_if { |data| data[1] <= 0 }
  end
  
end

