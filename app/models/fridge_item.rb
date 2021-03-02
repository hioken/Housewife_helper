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
  def self.lack_ingredients(user, ingredients, size = 1)
    lacks = ingredients.pluck(:name, :amount, :unit).each {|data| data[1] *= size}
    names = lacks.map { |data| data[0] }
    fridge_items = user.fridge_items.joins(:ingredient).where('ingredients.name': names).pluck('ingredients.name', :amount).to_h
    lacks.each { |data| data[1] -= fridge_items[data[0]] if fridge_items[data[0]] }.delete_if { |data| data[1] < 1 }
  end
  
end

