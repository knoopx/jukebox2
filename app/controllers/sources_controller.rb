class SourcesController < InheritedResources::Base
  actions :all, :except => [:new, :show]
  before_filter :build_resource, :only => :index

  def reindex
    flash[:notice] = "Now scanning for new releases"
    Rails.queue.clear
    Source.all.each do |source|
      Rails.queue.push do
        Rails.logger.info "Indexing #{source.path}"

        Jukebox2::Indexer.each_release(source.path) do |release_path|
          Rails.queue.push { Jukebox2::Indexer.index_release(release_path) }
        end
      end
    end

    redirect_to sources_path
  end
end