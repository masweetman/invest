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
    q = yahoo.quotes(Company.all.map{ |company| company.ticker }, [:symbol, :last_trade_price, :change_in_percent, :market_capitalization, :stock_exchange])
    q.map{ |quote|
      c = Company.find_by_ticker(quote.symbol)
      if (quote.stock_exchange == 'NYQ' || quote.stock_exchange == 'NMS')
        c.update_quote(quote)
      else
        c.destroy
      end
    }
  end

  def update_all_ratio_data
    Company.where(require_update: true).each do |company|
      c.scrape
      sleep(rand(1..3))
    end
  end


end
