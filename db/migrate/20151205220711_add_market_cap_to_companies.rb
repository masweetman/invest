class AddMarketCapToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :market_cap, :string
  end
end
