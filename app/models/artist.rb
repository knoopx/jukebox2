require 'open-uri'

class Artist < ActiveRecord::Base
  include Jukebox2::Favorites::ModelMethods

  has_and_belongs_to_many :releases, :order => :year.desc
  has_many :taggings, :uniq => true
  has_many :tracks
  has_many :genres, :through => :taggings, :uniq => true

  scope :recent, lambda { |limit| order(:created_at.desc).limit(limit) }
  scope :genres_id_in, lambda { |genres| joins(:taggings).where(:taggings => {:genre_id => genres}) }
  scope :genres_id_not_in, lambda { |genres| joins(:taggings).where(:taggings => {:genre_id.not_in => genres}) }

  scope :genres_name_in, lambda { |genres_names|
    genres = genres_names.split(",").map { |name| Genre.where(:name.like => "%#{name.strip}%").first }.reject(&:blank?)
    joins(:taggings).
        where(:taggings => {:genre_id => genres}).
        group("artist_id").
        having("COUNT(artist_id) = ?", genres.size)
  }

  search_method :genres_name_in

  validates_presence_of :normalized_name, :name
  validates_uniqueness_of :name

  before_save :normalize_name
  after_create :update_metadata, :update_similar_artists

  serialize :similar_mbids, Array
  serialize :images, Hash

  def random_track
    releases.map(&:tracks).flatten.sample
  end

  def similar
    similar_mbids.nil? ? [] : self.class.where(:mbid => similar_mbids)
  end

  def image_url(format = :large)
    self.images[format]
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
      self.update_attributes :name => artist["name"],
                             :mbid => artist["mbid"],
                             :lastfm_url => artist["url"],
                             :listeners => artist["stats"]["listeners"],
                             :play_count => artist["stats"]["playcount"],
                             :images => artist["image"].each_with_object({}) { |image, hash| hash[image["size"].to_sym] = image["#text"] },
                             :summary => artist["bio"]["summary"],
                             :biography => artist["bio"]["content"]

      self.genres = Array.wrap(artist["tags"]["tag"]).map { |tag| Genre.find_or_create_by_name(tag["name"]) }
    end
  end

  def update_similar_artists
    begin
      # http://ws.audioscrobbler.com/2.0/?api_key=b25b959554ed76058ac220b7b2e0a026&method=artist.getsimilar&artist=kidcrash
      response = Nestful.get("http://ws.audioscrobbler.com/2.0/", :format => :json, :params => {
          :api_key => "b25b959554ed76058ac220b7b2e0a026",
          :format => "json",
          :method => "artist.getsimilar",
          :artist => self.name
      })

      update_attribute :similar_mbids, response["similarartists"]["artist"].map { |a| a["mbid"] }.reject(&:blank?)
    rescue => e
      puts e
    end
  end

  class << self
    def reset_counters!
      transaction do
        self.find_each do |artist|
          self.reset_counters(artist.id, :tracks)
        end
      end
    end
  end
  protected

  def normalize_name
    self.normalized_name = self.name.to_slug.normalize.to_s
  end
end
