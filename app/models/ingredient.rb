class Ingredient < ApplicationRecord
  # Setting
  has_many :fridge_items
  
  enum unit: [:合, :g, :切れ, :個, :本, :玉, :枚, :粒, :パック, :option]
  enum html_color: [:silver, :red, :orange, :green, :lime, :black]
  
  # Methods
  scope :genre_scope, -> (genre) { where(id: GENRE_SCOPE[genre]) }
  
  def name_unit
    unless GENRE_SCOPE[:grain_seasoning].include?(self.id)
      "#{self.name} 単位:#{self.unit}"
    else
      name
    end
  end
end