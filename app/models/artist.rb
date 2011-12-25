require 'open-uri'

class Artist < ActiveRecord::Base
  include Jukebox2::Favorites::ModelMethods

  has_and_belongs_to_many :releases, :order => :year.desc
  has_many :taggings
  has_many :tracks
  has_many :genres, :through => :taggings

  scope :recent, lambda { |limit| order(:created_at.desc).limit(limit) }
  scope :genres_id_in, lambda { |genres| joins(:genres).where(:genres => {:id => genres}).group("artists.id") }
  scope :genres_id_not_in, lambda { |genres| ap genres; joins(:taggings).where(:taggings => {:genre_id.not_in => genres}).group("artists.id") }

  validates_presence_of :normalized_name, :name
  validates_uniqueness_of :name

  before_save :normalize_name
  after_create :update_metadata, :update_similar_artists

  serialize :similar_mbids

  def random_track
    releases.map(&:tracks).flatten.sample
  end

  def similar
    similar_mbids.nil? ? [] : self.class.where(:mbid => similar_mbids)
  end

  def update_metadata
    response = Nestful.get("http://ws.audioscrobbler.com/2.0/", :format => :json, :params => {
        :api_key => "b25b959554ed76058ac220b7b2e0a026",
        :format => "json",
        :method => "artist.getinfo",
        :artist => self.name
    })

    # todo: use last.fm artist instead of the one from id3!

    response["artist"].tap do |artist|
      update_attributes :name => artist["name"],
                        :mbid => artist["mbid"],
                        :lastfm_url => artist["url"],
                        :image_url => artist["image"].last["#text"],
                        :listeners => artist["stats"]["listeners"],
                        :play_count => artist["stats"]["playcount"],
                        :summary => artist["bio"]["summary"],
                        :biography => artist["bio"]["content"]

      self.genres = Array.wrap(artist["tags"]["tag"]).map { |tag| Genre.find_or_create_by_name(tag["name"]) }
    end
  end

  def update_similar_artists
    # http://ws.audioscrobbler.com/2.0/?api_key=b25b959554ed76058ac220b7b2e0a026&method=artist.getsimilar&artist=kidcrash
    response = Nestful.get("http://ws.audioscrobbler.com/2.0/", :format => :json, :params => {
        :api_key => "b25b959554ed76058ac220b7b2e0a026",
        :format => "json",
        :method => "artist.getsimilar",
        :artist => self.name
    })

    update_attribute :similar_mbids, response["similarartists"]["artist"].map { |a| a["mbid"] }.reject(&:blank?)
  end

  protected

  def normalize_name
    self.normalized_name = self.name.to_slug.normalize.to_s
  end
end
