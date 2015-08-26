require 'financials'

class CompaniesController < ApplicationController

	def index
		if params[:sort].present? && params[:direction].present?
			@companies = Company.order(params[:sort] + ' ' + params[:direction]) 
		else
			@companies = Company.all
		end
	end

	def show
		@company = Company.find(params[:id])
		financials = Financials.new
		financials.update_ratios(@company)
	end
	
	def new
		@company = Company.new
	end

	def create
		@company = Company.new(company_params)

		if @company.save
			redirect_to companies_path
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

	def update
		financials = Financials.new
		financials.update_all_tickers if params[:element] == 'tickers'
		financials.update_all_quotes if params[:element] == 'quotes'
	end

private
	def company_params
		params.require(:company).permit(:ticker)
	end
end
