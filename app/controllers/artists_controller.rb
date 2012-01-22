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

  def update_metadata
    resource.update_metadata
    redirect_to resource
  end
end