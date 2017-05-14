class AddUpdatesToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :require_update, :boolean, :default => true
    add_column :companies, :no_data, :boolean, :default => false
  end
end
