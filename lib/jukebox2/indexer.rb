require 'fileutils'

module Jukebox2
  class Indexer
    class << self
      def each_release(source, &block)
        raise "No block given" unless block_given?
        raise "#{source} is not a directory" unless File.directory?(source)

        releases = []

        Dir.glob(File.join(source, "**", "*.mp3")).each do |file|
          release_path = File.expand_path(File.dirname(file))
          unless releases.include?(release_path)
            releases << release_path
            yield(release_path)
          end
        end
      end

      def index_release(release_path)
        Rails.logger.info "Processing #{File.basename(release_path)}"
        begin
          Release.find_or_create_by(:path => release_path)
        rescue Exception => e
          Rails.logger.error "Error processing #{relase_path}: #{e}:\r\n#{e.backtrace.join("\r\n")}"
        end
      end
    end
  end
end