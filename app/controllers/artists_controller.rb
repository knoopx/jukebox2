class ArtistsController < InheritedResources::Base
  include Jukebox2::Favorites::ControllerMethods

  belongs_to :genre, :optional => true

  set_default_sort_attribute :name

  apply_filtering
  apply_sorting
  apply_search
  apply_pagination

  has_scope :genres_id_in, :type => :array
  has_scope :genres_id_not_in, :type => :array

  def merge
    @artists = Artist.find(params[:artist_ids])

    if params[:primary_artist_id]
      @primary_artist = Artist.find(params[:primary_artist_id])
      @primary_artist.merge_with(@artists)
      redirect_to @primary_artist
    end
  end

  def update_metadata
    resource.update_metadata
    resource.update_similar_artists
    redirect_to resource
  end
end