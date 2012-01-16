class SourcesController < InheritedResources::Base
  actions :all, :except => [:new, :show]
  before_filter :build_resource, :only => :index

  def reindex
    system "bundle exec rake jukebox2:scan RAILS_ENV=#{Rails.env} &"
    flash[:notice] = "Now scanning for new releases"
    redirect_to sources_path
  end
end