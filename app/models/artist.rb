require 'open-uri'

class Artist
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable
  include Jukebox2::Favorites::ModelMethods
  include Jukebox2::Search::Scope

  field :name
  field :normalized_name
  field :summary
  field :biography
  field :lastfm_url

  field :mbid
  field :similar_mbids, :type => Array, :default => []

  field :images, :type => Hash, :default => {}

  field :favorited_at, :type => DateTime

  field :listeners, :type => Integer, :default => 0
  field :play_count, :type => Integer, :default => 0

  field :tracks_count, :type => Integer, :default => 0
  field :releases_count, :type => Integer, :default => 0

  key :normalized_name
  index :mbid, :uniq => true

  has_and_belongs_to_many :releases, :dependent => :destroy, :order => :year.desc
  has_many :tracks

  validates_presence_of :normalized_name, :name
  validates_uniqueness_of :name

  scope :recent, lambda { |limit| desc(:created_at).limit(limit) }
  scope :name_like, lambda { |name| where(:name => /#{name}/i) }
  scope :tagged, lambda { |tags| tagged_with_all(tags.split(", ")) }

  search_scope :name_like
  search_scope :tagged

  before_save :normalize_name
  after_create :update_metadata, :update_similar_artists

  def random_track
    releases.map(&:tracks).flatten.sample
  end

  def similar
    self.class.any_in(:mbid => similar_mbids)
  end

  def image_url(format = "large")
    self.images[format]
  end

  def update_metadata
    begin
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
                               :biography => artist["bio"]["content"],
                               :tags_array => Array.wrap(artist["tags"]["tag"]).map { |tag| tag["name"] }
      end
    rescue => e
      puts e
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
      self.all.each do |artist|
        self.reset_counters(artist.id, :tracks)
      end
    end
  end

  protected

  def normalize_name
    self.normalized_name = self.name.to_slug.normalize.to_s
  end
end
