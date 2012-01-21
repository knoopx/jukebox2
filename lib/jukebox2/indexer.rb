require 'fileutils'

module Jukebox2
  class Indexer
    LOCK_FILE = Rails.root.join("tmp", "index.lock")

    class Exception < ::Exception
    end

    def initialize
      self.class.lock do
        Source.all.each do |source|
          puts "Indexing #{source.path}"
          each_release(source.path) do |release_path|
            index_release(release_path)
          end
        end
      end
    end

    def self.running?
      File.exist?(LOCK_FILE)
    end

    protected

    def self.lock(&block)
      begin
        unless running?
          File.open(LOCK_FILE, "wb") do |f|
            f.write(Process.pid)
          end
          yield
        else
          raise Exception.new("An indexing process is already running.")
        end
      ensure
        File.delete(LOCK_FILE)
      end
    end

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
      puts " * Processing #{File.basename(release_path)}"
      begin
        Release.find_or_create_by(:path => release_path)
      rescue Exception => e
        puts " !!! #{e}:\r\n#{e.backtrace.join("\r\n")}"
      end
    end
  end
end