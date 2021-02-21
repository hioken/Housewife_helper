class Ingredient < ApplicationRecord
  # Class
  ## CONSTANT
  GENRE_SCOPE = {
    meat: 100..499, fish: 500..999, meat_fish: 100..999,
    vegetable: 1000..2999,
    fluit: 3000..3499, fungi: 3500..3999, herb: 4000..4999, other: 3000..4999,
    grain: 5000..5499, seasoning: 5500..6999, grain_seasoning: 5000..6999
  }
  
  
  # Database
  
  ## Table
  ### assciation
  has_many :fridge_items
  
  ## Column
  ### ENUM
  enum unit: [:合, :g, :切れ, :個, :本, :玉, :枚, :粒, :パック, :option]
  enum html_color: [:silver, :red, :orange, :green, :lime, :black]
end