require 'modules/ingredient_data_giver.rb'
class EndUser < ApplicationRecord
  include IngredientDataGiber
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # assciation
  has_many :fridge_items
end
