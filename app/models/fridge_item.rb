require 'modules/user_ingredient_manager.rb'

class AmountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.ingredient.unit == 'g'
      record.errors.add(attribute, 'が想定されていない数値です。') if value < 200
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
end

