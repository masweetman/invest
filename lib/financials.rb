class Financials

  def yahoo
    yahoo = YahooFinance::Client.new
  end

  def update_all_tickers
    companies = Company.where(:exchange => 'NYSE').map{ |c| c.ticker }
    tickers = yahoo.symbols_by_market('us', 'nyse').map{ |t| t.gsub('.','-') }
    new_companies = tickers - companies
    new_companies.each do |n|
      unless n.include? '^'
        c = Company.create
        c.ticker = n
        c.exchange = 'NYSE'
        c.save
      end
    end
    old_companies = companies - tickers
    old_companies.each do |o|
      c = Company.find_by_ticker(o)
      unless c.nil?
        c.destroy
      end
    end

    companies = Company.where(:exchange => 'NASDAQ').map{ |c| c.ticker }
    tickers = yahoo.symbols_by_market('us', 'nasdaq').map{ |t| t.gsub('.','-') }
    new_companies = tickers - companies
    new_companies.each do |n|
      unless n.include? '^'
        c = Company.create
        c.ticker = n
        c.exchange = 'NASDAQ'
        c.save
      end
    end
    old_companies = companies - tickers
    old_companies.each do |o|
      c = Company.find_by_ticker(o)
      unless c.nil?
        c.destroy
      end
    end
  end

  def update_all_quotes
    Company.all.each do |c|
        c.quote
    end
  end

  def update_all_ratio_data
    Company.where(require_update: true).each do |company|
      company.scrape
      puts "Getting data for id " + company.id.to_s + ": " + company.ticker
      sleep(rand(1..3))
    end
  end


end
