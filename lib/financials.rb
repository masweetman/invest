require 'nokogiri'
require 'open-uri'

class Financials

	def yahoo
		yahoo = YahooFinance::Client.new
	end

	def get_quote(company)
		quote = yahoo.quote(company.ticker)
		update_quote(company, quote)
		update_ratios(company)
	end

	def get_data(company)
		command = 'casperjs '
		command += Rails.root.join('app/assets/javascripts/get_data.js').to_s
		command += ' ' + company.ticker.gsub('-','.')
		command += ' ' + Rails.root.to_s
		html = %x[ #{command} ]
		html = Nokogiri::HTML(html)
		update_data(company, html)
		update_ratios(company)
	end

	def update_all_tickers
		companies = Company.all.map{ |c| c.ticker }

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
	end

	def update_all_quotes
		quotes = yahoo.quotes(Company.all.map{ |c| c.ticker })
		quotes.map{ |q|
			c = Company.find_by_ticker(q.symbol)
			update_quote(c, q)
			update_ratios(c)
		}
	end

	def update_all_ratio_data
		Company.all.each do |company|
			get_data(company)
			sleep(5)
		end
	end

	def update_quote(company, quote)
		unless company.nil?
			company.price = quote.last_trade_price.to_f
			company.price_change_pct = quote.change.to_f / quote.previous_close.to_f unless quote.previous_close.to_f == 0
			company.save
		end
	end

	def update_ratios(company)
		earnings = company.earnings.where('year >= ? AND year <= ?', Date.current.year - 6, Date.current.year).map { |e| e.value }
		average = earnings.sum / earnings.length.to_f unless earnings.length.to_f == 0

		last_div = company.dividends.map{ |d| d.year }.max
		if company.dividends.where(year: last_div).any?
			dividend = company.dividends.where(year: last_div).last.value.to_f
		else
			dividend = 0.0
		end
		
		company.calculated_pe = company.price.to_f / average unless average.to_f == 0
		company.div_yield = dividend / company.price.to_f unless company.price.to_f == 0

		company.save
	end

	def update_data(company, html)
		update_eps(company, html)
		update_div(company, html)
	end

	def update_eps(company, html)
		titles = html.css('table.r_table1 thead tr th[id^="Y"]').map do |i|
			i.content
		end
		eps = html.css('td[headers$="i5"]').map do |i|
			i.content
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