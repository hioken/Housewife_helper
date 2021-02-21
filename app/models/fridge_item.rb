class FridgeItem < ApplicationRecord
  # Database
  
  ## Table
  ### assciation
  belongs_to :end_user
  belongs_to :ingredient
  
end

=begin
  scope :all_genre, -> 
  scope :scope_genre, -> (genre) {joins(:ingredient).where(ingredient_id: genre, user_id: current_end_user)}
=end