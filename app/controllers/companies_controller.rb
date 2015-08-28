require 'financials'

class CompaniesController < ApplicationController

	def index
		scope = Company.all
		if params[:sort].present? && params[:direction].present?
			scope = scope.order(params[:sort] + ' ' + params[:direction]) 
		end
		if params[:ticker].present?
			scope = scope.where("ticker LIKE '#{params[:ticker].upcase}%'")
		end
		@companies = scope.paginate(:page => params[:page], :per_page => 30)
	end

	def show
		@company = Company.find(params[:id])
		financials = Financials.new

		if @company.earnings.empty?
			financials.get_data(@company)
		end
		
		financials.get_quote(@company)
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
		financials.update_all_ratio_data if params[:element] == 'data'
		financials.update_all_quotes if params[:element] == 'quotes'
	end

private
	def company_params
		params.require(:company).permit(:ticker)
	end
end
