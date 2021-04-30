class ApplicationRecord < ActiveRecord::Base
  # Setting
  self.abstract_class = true
  
  # CONSTANT
  GENRE_SCOPE = {
  	all: 1..6999, semi_all: 100..6999, not_seasoning: 100..5499,
  	meat: 100..499, fish: 500..999, meat_fish: 100..999,
  	vegetable: 1000..2999,
  	fluit: 3000..3499, fungi: 3500..3999, herb: 4000..4999, other: 3000..4999,
  	grain: 5000..5499, seasoning: 5500..6999, grain_seasoning: 5000..6999
  }
  
	 BOOLEAN_AMOUNT = 2147483646 
end
