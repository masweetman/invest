class AddLastUpdateToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :last_earnings_update, :date
  end
end
