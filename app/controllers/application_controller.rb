class ApplicationController < ActionController::Base
  protect_from_forgery

  include InheritedResources::ControllerScopes
  include Jukebox2::Navigation

  before_filter :pjax

  class << self
    def paginate(opts = {})
      scoped(opts.merge(:only => :index)) do |target|
        target.page(params.fetch(:page, 1))
      end
    end

    def search(scope = :search)
      scoped(:only => :index) do |target|
        target.scoped.scoped_search(params[scope])
      end
    end

    def apply_filter_scopes
      scoped(:only => :index) do |target|
        if scope = params[:scope]
          set_current_tab scope, :scope
          target.send(scope)
        else
          set_current_tab :default, :scope
          target
        end
      end
    end
  end

  def pjax
    if request.headers['X-PJAX']
      render :layout => false
    end
  end
end
