class AddMonthToEarnings < ActiveRecord::Migration
  def change
    add_column :earnings, :month, :integer
  end
end
