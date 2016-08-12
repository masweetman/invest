require 'financials'

class CompaniesController < ApplicationController

  def index
    scope = Company.all
    scope = scope.order(params[:sort] + ' ' + params[:direction]) if params[:sort].present? && params[:direction].present?
    scope = scope.where("lower(ticker) LIKE '#{params[:search].downcase}%' OR lower(name) LIKE '#{params[:search].downcase}%'").order("ticker") if params[:search].present?
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
    query_params['min_cap'] = q.min_cap_val if q.min_cap_val
    query_params['max_cap'] = q.max_cap_val if q.max_cap_val
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
      query += 'market_cap_val >= ' + param[1].to_s if param[0] == 'min_cap'
      query += 'market_cap_val <= ' + param[1].to_s if param[0] == 'max_cap'
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

  def update
    @company = Company.find(params[:id])

    if @company.update(company_params)
      redirect_to company_path(@company)
    end
  end

  def update_quotes
    financials = Financials.new
    financials.update_all_quotes
  end

private
  def company_params
    params.require(:company).permit(:ticker, :favorite, :comment)
  end
end
