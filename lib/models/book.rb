class Book < ActiveRecord::Base 
    belongs_to :lender
    has_many :checkouts
    has_many :borrowers, through: :checkouts 
end
