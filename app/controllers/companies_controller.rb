require 'financials'

class CompaniesController < ApplicationController

	def index
		scope = Company.all
		scope = scope.order(params[:sort] + ' ' + params[:direction]) if params[:sort].present? && params[:direction].present?
		scope = scope.where("lower(ticker) LIKE '#{params[:ticker].downcase}%'").order("ticker") if params[:ticker].present?
		scope = scope.where("lower(name) LIKE '#{params[:name].downcase}%'").order("ticker") if params[:name].present?
		scope = build_query(scope, params[:query_id]) if params[:query_id].present?
		@companies = scope.paginate(:page => params[:page], :per_page => 30)
	end

	def build_query(scope, query_id)
		q = Query.find(query_id)
		query_params = {}
		query_params['min_pe'] = q.min_pe if q.min_pe
		query_params['max_pe'] = q.max_pe if q.max_pe
		query_params['min_p_to_bv'] = q.min_p_to_bv if q.min_p_to_bv
		query_params['max_p_to_bv'] = q.max_p_to_bv if q.max_p_to_bv
		query_params['min_div'] = q.min_div if q.min_div
		query_params['max_div'] = q.max_div if q.max_div
		query_params['favorites'] = q.favorites if q.favorites

		query = ''
		i = 0

		query_params.each do |param|
			query += 'calculated_pe >= ' + param[1].to_s if param[0] == 'min_pe'
			query += 'calculated_pe <= ' + param[1].to_s if param[0] == 'max_pe'
			query += 'p_to_bv >= ' + param[1].to_s if param[0] == 'min_p_to_bv'
			query += 'p_to_bv <= ' + param[1].to_s if param[0] == 'max_p_to_bv'
			query += '(div_yield*100) >= ' + param[1].to_s if param[0] == 'min_div'
			query += '(div_yield*100) <= ' + param[1].to_s if param[0] == 'max_div'
			query += 'favorite = 1' if param[0] == 'favorites' && q.favorites == true

			i += 1
			unless i >= query_params.length
				query += ' AND '
			end
		end
		scope = scope.where(query)
		scope = scope.order(q.sort_criteria) if q.sort_criteria
		scope
	end

	def show
		@company = Company.find(params[:id])
		financials = Financials.new

		financials.get_data(@company) if (@company.name.nil? || @company.updated_at.to_date <= (Date.today - 1.month))
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

	#def destroy
	#	@company = Company.find(params[:id])
	#	@company.earnings.each do |e|
	#		e.destroy
	#	end
	#	@company.dividends.each do |d|
	#		d.destroy
	#	end
	#	@company.destroy
	#
	#	redirect_to companies_path
	#end

	def update
		@company = Company.find(params[:id])

		if @company.update(company_params)
			redirect_to company_path(@company)
		end
	end

private
	def company_params
		params.require(:company).permit(:ticker, :favorite, :comment)
	end
end
