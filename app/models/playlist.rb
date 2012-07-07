require 'active_support/concern'

class Playlist
  module Registry
    extend ActiveSupport::Concern

    included do
      @playlists = {}
    end

    module ClassMethods
      def all
        @playlists
      end

      def find(name)
        @playlists[name.to_sym]
      end

      def register(name, &block)
        @playlists[name] = Object.const_set(name.to_s.classify, Class.new do
          extend ActiveModel::Naming
          define_method(:tracks, &block)
        end).new
      end
    end
  end

  include Registry

  register(:favorite_artists) { Track.where(:artist_id.in => Artist.favorited.map(&:id)) }
  register(:favorite_releases) { Track.where(:release_id.in => Release.favorited.map(&:id)) }
  register(:favorite_tracks) { Track.favorited }
end