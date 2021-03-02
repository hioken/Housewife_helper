class UserMenu < ApplicationRecord
  #Setting
  belongs_to :end_user
  belongs_to :recipe
  
  #Methods
end
