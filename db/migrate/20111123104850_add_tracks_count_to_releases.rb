class AddTracksCountToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :tracks_count, :integer, :default => 0
  end
end
