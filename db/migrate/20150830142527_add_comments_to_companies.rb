class AddCommentsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :comment, :text
    add_column :companies, :favorite, :boolean
  end
end
