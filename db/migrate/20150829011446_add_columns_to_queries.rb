class AddColumnsToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :min_p_to_bv, :float
    add_column :queries, :max_p_to_bv, :float
  end
end
