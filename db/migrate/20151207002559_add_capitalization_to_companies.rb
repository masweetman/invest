class AddCapitalizationToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :market_cap_val, :float
    add_column :companies, :market_cap_order, :string
  end
end
