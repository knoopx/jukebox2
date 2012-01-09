class AddFavoritedAtToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :favorited_at, :datetime
  end
end
