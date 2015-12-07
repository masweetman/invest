class AddCapitalizationToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :min_cap_val, :float
    add_column :queries, :min_cap_order, :string
    add_column :queries, :max_cap_val, :float
    add_column :queries, :max_cap_order, :string
  end
end
