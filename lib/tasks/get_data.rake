require 'financials'

namespace :invest do

  task :update_tickers => :environment do
    financials = Financials.new
    financials.update_all_tickers
    financials.update_all_quotes
  end

  task :get_data => :environment do
    financials = Financials.new
    financials.update_all_ratio_data
  end

  task :update_quotes => :environment do
    financials = Financials.new
    financials.update_all_quotes
  end

end