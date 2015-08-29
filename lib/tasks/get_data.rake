require 'financials'

namespace :invest do

	task :update_tickers => :environment do
		financials = Financials.new
		financials.update_all_tickers
	end

	task :get_data => :environment do
		financials = Financials.new
		financials.update_all_ratio_data(Company.all)
	end

	task :get_data0 => :environment do
		financials = Financials.new
		financials.update_all_ratio_data(Company.where('id < 1000'))
	end

	task :get_data1 => :environment do
		financials = Financials.new
		financials.update_all_ratio_data(Company.where('id >= 1000 AND id < 2000'))
	end

	task :get_data2 => :environment do
		financials = Financials.new
		financials.update_all_ratio_data(Company.where('id >= 2000 AND id < 3000'))
	end

	task :get_data3 => :environment do
		financials = Financials.new
		financials.update_all_ratio_data(Company.where('id >= 3000 AND id < 4000'))
	end

	task :get_data4 => :environment do
		financials = Financials.new
		financials.update_all_ratio_data(Company.where('id >= 4000 AND id < 5000'))
	end

	task :get_data5 => :environment do
		financials = Financials.new
		financials.update_all_ratio_data(Company.where('id >= 5000 AND id < 6000'))
	end

	task :get_data6 => :environment do
		financials = Financials.new
		financials.update_all_ratio_data(Company.where('id >= 6000'))
	end

	task :update_quotes => :environment do
		financials = Financials.new
		financials.update_all_quotes
	end

end