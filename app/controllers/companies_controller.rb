require 'nokogiri'
require 'open-uri'

class CompaniesController < ApplicationController
	def index
		@companies = Company.all
		update_data
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

	def update_data
		Company.all.each do |company|
			filename = company.ticker + '.html'
			filepath = Rails.root.join('data/' + filename)

			if File.exist? filepath
				page = Nokogiri::HTML(open(filepath))

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
		end
	end

private
	def company_params
		params.require(:company).permit(:ticker)
	end
end
