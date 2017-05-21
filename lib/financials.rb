require 'nokogiri'
require 'open-uri'
require 'transient_cache'

class Financials

  def yahoo
    yahoo = YahooFinance::Client.new
  end

  def get_data(company)
    a = 'casperjs '
    a += Rails.root.join('app/assets/javascripts/get_data.js').to_s
    a += ' ' + company.ticker.gsub('-','.')
    a += ' ' + Rails.root.to_s
    h = %x[ #{a} ]
    n = Nokogiri::HTML(h)
    update_data(company, n)
  end

  def get_quote(company)
    quote = yahoo.quote(company.ticker, [:symbol, :last_trade_price, :change_in_percent, :market_capitalization, :stock_exchange])
    if (quote.stock_exchange == 'NYQ' || quote.stock_exchange == 'NMS')
      update_quote(company, quote)
      update_ratios(company)
    else
      company.destroy
    end
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
        update_quote(c, quote)
        update_ratios(c)
      else
        c.destroy
      end
    }
  end

  def update_all_ratio_data
    Company.where(require_update: true).each do |company|
      get_data(company)
      sleep(rand(1..3))
    end
  end

  def update_quote(company, quote)
    unless company.nil?
      company.price = quote.last_trade_price.to_f
      company.price_change_pct = quote.change_in_percent.to_f
      company.market_cap = quote.market_capitalization
      if company.market_cap.last == 'M'
        company.market_cap_val = company.market_cap.to_f
      elsif company.market_cap.last == 'B'
        company.market_cap_val = company.market_cap.to_f * 1000
      end

      if (company.no_data == false && company.last_earnings_update.nil?) ||
         (company.no_data == false && (Date.today > company.last_earnings_update + Setting.update_frequency_days.value.to_i.days))
        company.require_update = true
      else
        company.require_update = false
      end

      company.save
    end
  end

  def update_ratios(company)
    earnings = company.earnings.where('year >= ? AND year <= ?', Date.current.year - 6, Date.current.year).map { |e| e.value }
    average = (earnings.sum.round(3) / earnings.length).round(3) unless earnings.length == 0

    last_div = company.dividends.map{ |d| d.year }.max
    if company.dividends.where(year: last_div).any?
      dividend = company.dividends.where(year: last_div).last.value.to_f
    else
      dividend = 0.0
    end

    company.calculated_pe = company.price.to_f / average unless average.to_f == 0
    company.div_yield = dividend / company.price.to_f unless company.price.to_f == 0
    company.p_to_bv = company.price.to_f / company.bv_per_share.to_f unless company.bv_per_share.to_f == 0

    company.save
  end

  def update_data(company, html)
    company.name = html.css('div.wrapper div.r_bodywrap div.r_header div.reports_nav div.r_title h1')[0].content if html.css('div.wrapper div.r_bodywrap div.r_header div.reports_nav div.r_title h1')[0]
    if company.name.nil? || company.name.downcase.include?("pref share")
      company.no_data = true unless company.earnings.any?
    else
      company.bv_per_share = html.css('td[headers$="i8"]')[9].content.to_f if html.css('td[headers$="i8"]')[9]
      update_eps(company, html)
      update_div(company, html)
      company.last_earnings_update = Date.today
      company.require_update = false
    end
    company.save
  end

  def update_eps(company, html)
    titles = html.css('table.r_table1 thead tr th[id^="Y"]').map do |i|
      i.content
    end
    eps = html.css('td[headers$="i5"]').map do |i|
      i.content
    end

    if titles.length == 0
      company.no_data = true unless company.earnings.any?
    end

    unless titles.length == 0 || eps.length == 0
      earnings_per_share = Hash.new
      titles.each_with_index do |title, earnings|
        if title.include?('-')
          dateComponents = title.split /-/
          earnings_per_share[dateComponents[0].to_i] = eps[earnings].to_f unless eps[earnings].to_f == 0
        end
      end
      earnings_per_share.each do |eps|
        if company.earnings.where(year: eps[0]).empty?
          e = company.earnings.create
        else
          e = company.earnings.where(year: eps[0]).last
        end
        e.year = eps[0]
        e.value = eps[1]
        e.save
      end
    end
  end

  def update_div(company, html)
    titles = html.css('table.r_table1 thead tr th[id^="Y"]').map do |i|
      i.content
    end
    divs = html.css('td[headers$="i6"]').map do |i|
      i.content
    end

    unless titles.length == 0 || divs.length == 0
      dividends = Hash.new
      titles.each_with_index do |title, dividend|
        if title.include?('-')
          dateComponents = title.split /-/
          dividends[dateComponents[0].to_i] = divs[dividend].to_f unless divs[dividend].to_f == 0 
        end
      end
      dividends.each do |divs|
        if company.dividends.where(year: divs[0]).empty?
          d = company.dividends.create
        else
          d = company.dividends.where(year: divs[0]).last
        end
        d.year = divs[0]
        d.value = divs[1]
        d.save
      end
    end
  end

end
