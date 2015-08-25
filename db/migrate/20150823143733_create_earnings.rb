class CreateEarnings < ActiveRecord::Migration
  def change
    create_table :earnings do |t|
      t.float :value
      t.integer :year
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
