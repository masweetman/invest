class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :ticker
      t.float :price
      t.float :change
      t.float :calculated_pe
      t.float :div_yield

      t.timestamps null: false
    end
  end
end
