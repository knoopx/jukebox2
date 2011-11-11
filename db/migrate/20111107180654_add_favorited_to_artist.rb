class AddFavoritedToArtist < ActiveRecord::Migration
  def change
    add_column :artists, :favorited, :boolean, :default => false
  end
end
