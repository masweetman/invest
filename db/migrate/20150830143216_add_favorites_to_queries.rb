class AddFavoritesToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :favorites, :boolean
  end
end
