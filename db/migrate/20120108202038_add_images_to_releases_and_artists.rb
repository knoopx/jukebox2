class AddImagesToReleasesAndArtists < ActiveRecord::Migration
  def change
    add_column :artists, :images, :text
    add_column :releases, :images, :text
    remove_column :artists, :image_url
    remove_column :releases, :image_url
  end
end
