class AddDivColumnsToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :min_div, :float
    add_column :queries, :max_div, :float
  end
end
