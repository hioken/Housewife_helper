require 'modules/ingredient_data_giver.rb'
class EndUser < ApplicationRecord
  # setting
  include RelationIngredientDataGiber
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :fridge_items
  has_many :user_menus
  
  # Methods
end
