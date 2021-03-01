class UserMenu < ApplicationRecord
  belongs_to :end_user
  belongs_to :recipe
end
