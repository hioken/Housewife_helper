require 'modules/user_ingredient_manager.rb'

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
  extend UserIngredientManager
  
  belongs_to :end_user
  belongs_to :ingredient
  
  validates :amount, amount: true
  # Methods
  def self.lack_ingredients(user, ingredients, size: 1, ingredient_load: true)
    # 引数 => user: current_end_user, ingredients: 冷蔵庫と比較したい食材のリレーション, size: ingredientsのamountの量の倍率(人数), ingredient_load: falseならingredientをロードしない 
    # ロードする場合のSQLの発行を抑えるため1行で書いている
    # loadオプションがtrueのならingredientsテーブルをjoinsして配列化、そうでないならそのまま配列化
    lacks = ingredient_load ? ingredients.joins(:ingredient).pluck(:name, :amount, :unit, :ingredient_id) : ingredients.pluck(:name, :amount, :unit, :ingredient_id)
    # 水等の不要な食材をハッシュから削除、サイズオプションの倍率もかける
    lacks.delete_if { |data| data[1] *= size; !(self::GENRE_SCOPE[:semi_all].include?(data[3])) }
    # WHEREのIN句に使う名前を配列化
    names = lacks.map { |data| data[0] }
    # 冷蔵庫の対象と同じ素材を、名前とamountで取得
    fridge_items = user.fridge_items.joins(:ingredient).where('ingredients.name': names).pluck('ingredients.name', :amount).to_h
    lacks.each { |data| data[1] -= fridge_items[data[0]] if fridge_items[data[0]] }.delete_if { |data| data[1] < 1 }
  end
  
end

