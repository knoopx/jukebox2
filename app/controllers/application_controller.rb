class ApplicationController < ActionController::Base
  protect_from_forgery

  include InheritedResources::ControllerScopes
  include Jukebox2::Navigation

  before_filter :pjax

  class << self
    def includes(includes, *opts)
      scoped(*opts) do |target|
        target.includes(includes)
      end
    end

    def paginate
      scoped(:only => :index) do |target|
        target.page(params.fetch(:page, 1))
      end
    end

    def order(value)
      scoped(:only => :index) do |target|
        target.order(value)
      end
    end

    def search(scope = :search)
      scoped(:only => :index) do |target|
        instance_variable_set("@#{scope}", target.search(params[:search]))
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
      self.class.layout false
    end
  end
end
