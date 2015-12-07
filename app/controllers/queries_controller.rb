class QueriesController < ApplicationController
	def index
		@queries = Query.all
	end

	def new
		@query = Query.new
	end

	def create
		@query = Query.new(query_params)

		if @query.save
			redirect_to queries_path
		else
			render 'new'
		end
	end

	def destroy
		@query = Query.find(params[:id])
		@query.destroy
		redirect_to companies_path
	end

	def edit
		@query = Query.find(params[:id])
	end

	def update
		@query = Query.find(params[:id])

		if @query.update(query_params)
			redirect_to queries_path
		else
			render 'edit'
		end
	end

private
	def query_params
		params.require(:query).permit(:name, :min_pe, :max_pe, :min_p_to_bv, :max_p_to_bv, :min_div, :max_div, :favorites, :sort_criteria, :min_cap_val, :min_cap_order, :max_cap_val, :max_cap_order)
	end
end
