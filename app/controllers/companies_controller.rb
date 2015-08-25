require 'nokogiri'
require 'open-uri'

class CompaniesController < ApplicationController
	def index
		@companies = Company.all
		update_data unless Company.all.empty?
	end

	def show
		@company = Company.find(params[:id])
	end
	
	def new
		@company = Company.new
	end

	def create
		@company = Company.new(company_params)

		if @company.save
			redirect_to @company
		else
			render 'new'
		end
	end

	def destroy
		@company = Company.find(params[:id])
		@company.earnings.each do |e|
			e.destroy
		end
		@company.dividends.each do |d|
			d.destroy
		end
		@company.destroy

		redirect_to companies_path
	end

	def update_eps(company, page)
		titles = page.css('table.r_table1 thead tr th[id^="Y"]').map do |i|
			i.content
		end
		eps = page.css('td[headers$="i5"]').map do |i|
			i.content
		end

		unless titles.length == 0 || eps.length == 0
			earnings_per_share = Hash.new
			titles.each_with_index do |title, earnings|
				if title.include?('-')
					dateComponents = title.split /-/
					earnings_per_share[dateComponents[0].to_i] = eps[earnings].to_f
				end
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

	def update_div(company, page)
		titles = page.css('table.r_table1 thead tr th[id^="Y"]').map do |i|
			i.content
		end
		divs = page.css('td[headers$="i6"]').map do |i|
			i.content
		end

		unless titles.length == 0 || divs.length == 0
			dividends = Hash.new
			titles.each_with_index do |title, dividend|
				if title.include?('-')
					dateComponents = title.split /-/
					dividends[dateComponents[0].to_i] = divs[dividend].to_f
				end
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

	def update_data
		yahoo_client = YahooFinance::Client.new

		Company.all.each do |company|
			yahoo = yahoo_client.quote(company.ticker)
			company.price = yahoo.last_trade_price.to_f
			company.change = yahoo.change.to_f / yahoo.previous_close.to_f

			filename = company.ticker + '.html'
			filepath = Rails.root.join('data/' + filename)

			if File.exist? filepath
				page = Nokogiri::HTML(open(filepath))
				update_eps(company, page)
				
				earnings = company.earnings.where('year >= ? AND year <= ?',Date.current.year - 6, Date.current.year).map { |e| e.value }
				average = earnings.sum / earnings.length.to_f

				update_div(company, page)
				last_div = company.dividends.map{ |d| d.year }.max
				dividend = company.dividends.where(year: last_div).last.value
				
				company.calculated_pe = yahoo.last_trade_price.to_f / average
				company.div_yield = dividend / yahoo.last_trade_price.to_f
			end

			company.save

		end
	end

private
	def company_params
		params.require(:company).permit(:ticker)
	end
end
