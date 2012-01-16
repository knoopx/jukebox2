require 'iconv'

class ReleasesController < InheritedResources::Base
  include Jukebox2::Favorites::ControllerMethods
  apply_filter_scopes
  search
  paginate

  def update_metadata
    resource.update_metadata
    redirect_to resource
  end
end