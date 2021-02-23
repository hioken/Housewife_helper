require 'modules/ingredient_data_giver.rb'
class EndUser < ApplicationRecord
  # setting
  ## module file space is lib/modules
  include RelationIngredientDataGiber
  ## Include default devise modules. Others available are:
  ## :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  # Database
  ## association
  has_many :fridge_items
  ## Column
  
  # Class
  ## Method
  ## scope
end
