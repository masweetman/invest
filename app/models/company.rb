class Company < ActiveRecord::Base
  has_many :earnings
  has_many :dividends
  validates :ticker, presence: true, length: { minimum: 1 }
end
