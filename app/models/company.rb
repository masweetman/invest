class Company < ActiveRecord::Base
	has_many :earnings
	validates :ticker, presence: true, length: { minimum: 1 }
end
