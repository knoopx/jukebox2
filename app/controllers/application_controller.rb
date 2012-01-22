class ApplicationController < ActionController::Base
  protect_from_forgery

  include InheritedResources::ControllerScopes

  include Jukebox2::Navigation
  include Jukebox2::Filtering::ControllerMethods
  include Jukebox2::Search::ControllerMethods
  include Jukebox2::Sorting::ControllerMethods
  include Jukebox2::Pagination::ControllerMethods

  def _default_layout_with_pjax(*args)
    if request.headers['X-PJAX']
      false
    else
      _default_layout_without_pjax(*args)
    end
  end

  alias_method_chain :_default_layout, :pjax
end
