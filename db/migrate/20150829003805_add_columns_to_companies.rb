class AddColumnsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :name, :string
    add_column :companies, :bv_per_share, :float
    add_column :companies, :p_to_bv, :float
  end
end
