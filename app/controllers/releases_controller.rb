require 'iconv'

class ReleasesController < InheritedResources::Base
  include Jukebox2::Favorites::ControllerMethods

  set_default_sort_attribute :name

  apply_filtering
  apply_sorting
  apply_search
  apply_pagination

  def update_metadata
    resource.update_metadata
    redirect_to resource
  end
end