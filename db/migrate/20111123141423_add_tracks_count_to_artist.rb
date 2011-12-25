class AddTracksCountToArtist < ActiveRecord::Migration
  def change
    add_column :artists, :tracks_count, :integer, :default => 0
  end
end
