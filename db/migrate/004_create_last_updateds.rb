class CreateLastUpdateds < ActiveRecord::Migration
  def change
    create_table :last_updateds do |t|
      t.date :last_updated

      t.timestamps null: false
    end
  end
end
