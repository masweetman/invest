class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :name
      t.float :min_pe
      t.float :max_pe
      t.text :sort_criteria

      t.timestamps null: false
    end
  end
end
