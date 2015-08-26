require 'financials'

namespace :invest do

	task :get_data => :environment do
		financials = Financials.new

		Company.all.each do |company|
			financials.get_data(company)
		end
		
		if Setting.find_by_name("last_updated").nil?
			s = Setting.create
		else
			s = Setting.find_by_name("last_updated")
		end
		s.value = Date.current.to_s
		s.save
	end

	task :update_ratios => :environment do
		financials = Financials.new

		financials.update_all_quotes

		Company.all.each do |company|
			financials.update_ratios(company)
		end
	end
end