require 'financials'

class CompaniesController < ApplicationController

	def index
		scope = Company.all
		if params[:sort].present? && params[:direction].present?
			scope = scope.order(params[:sort] + ' ' + params[:direction]) 
		end
		if params[:ticker].present?
			scope = scope.where("ticker LIKE '#{params[:ticker].upcase}%'").order("ticker")
		end
		if params[:query_id].present?
			query = build_query(params[:query_id])
			scope = scope.where(query)
		end
		@companies = scope.paginate(:page => params[:page], :per_page => 30)
	end

	def build_query(id)
		q = Query.find(id)
		query_params = {}
		query_params['min_pe'] = q.min_pe if q.min_pe
		query_params['max_pe'] = q.max_pe if q.max_pe

		query = ''
		i = 0

		query_params.each do |param|
			query += 'calculated_pe >= ' + param[1].to_s if param[0] == 'min_pe'
			query += 'calculated_pe <= ' + param[1].to_s if param[0] == 'max_pe'
			i += 1
			unless i >= query_params.length
				query += ' AND '
			end
		end
		query
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
