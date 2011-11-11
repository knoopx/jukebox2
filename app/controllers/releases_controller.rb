require 'iconv'

class ReleasesController < ApplicationController
  include Jukebox2::Favorites::ControllerMethods
  apply_filter_scopes

  paginate

  def update_metadata
    resource.update_metadata
    redirect_to resource
  end
end