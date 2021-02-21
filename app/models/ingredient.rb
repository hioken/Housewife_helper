class Ingredient < ApplicationRecord
  # Database
  
  ## Table
  ### assciation
  has_many :fridge_items
  
  ## Column
  ### ENUM
  enum unit: [:合, :g, :切れ, :個, :本, :玉, :枚, :粒, :パック, :option]
  enum html_color: [:silver, :red, :orange, :green, :lime, :black]
end