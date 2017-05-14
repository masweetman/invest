class Company < ActiveRecord::Base
  has_many :earnings, :dependent => :destroy
  has_many :dividends, :dependent => :destroy
  validates :ticker, presence: true, length: { minimum: 1 }
end
