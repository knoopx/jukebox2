class ApplicationController < ActionController::Base
  protect_from_forgery

  include InheritedResources::ControllerScopes

  before_filter :pjax

  include Jukebox2::Navigation
  include Jukebox2::Filtering::ControllerMethods
  include Jukebox2::Search::ControllerMethods
  include Jukebox2::Sorting::ControllerMethods
  include Jukebox2::Pagination::ControllerMethods

  def pjax
    if request.headers['X-PJAX']
      render :layout => false
    end
  end
end
