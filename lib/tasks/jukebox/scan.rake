require 'jukebox2/indexer'

namespace :jukebox2 do
  task :artists => :environment do
    Artist.all.each do |artist|
      puts " * Processing #{artist.name}"
      artist.update_metadata
    end
  end

  task :releases => :environment do
    Release.all.each do |release|
      puts " * Processing #{release.name}"
      release.update_metadata
    end
  end

  task :prune => :environment do
    Release.all.each do |release|
      unless Dir.exist?(release.path)
        puts " * Removing #{release.path}"
        release.destroy
      end
    end
  end

  task :scan => :environment do
    Jukebox2::Indexer.new
  end
end