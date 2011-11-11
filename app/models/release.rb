class Release < ActiveRecord::Base
  include Jukebox2::Favorites::ModelMethods

  has_and_belongs_to_many :artists
  has_many :tracks, :dependent => :destroy

  validates_uniqueness_of :path
  before_save :process_release
  # after_create :update_metadata

  scope :recent, lambda { |limit| order(:created_at.desc).limit(limit) }

  def process_release
    self.name = File.basename(self.path)

    artists = []
    albums = []
    years = []

    Dir.glob(File.join(self.path, "*.mp3")) do |track_file|
      id3 = TagLib2::File.new(track_file)
      self.tracks.build do |track|
        track.number = id3.track
        track.title = id3.title
        track.filename = File.basename(track_file)
        track.sample_rate = id3.sample_rate
        track.bitrate = id3.bitrate
        track.channels = id3.channels
        track.length = id3.length
        track.artist = Artist.find_or_create_by_normalized_name(id3.artist.to_slug.normalize.to_s, :name => id3.artist)
        years << track.year unless years.include?(track.year)
      end

      artists << id3.artist unless artists.include?(id3.artist)
      albums << id3.album unless albums.include?(id3.album)
    end

    # raise Exception.new("Found tracks from multile albums") unless albums.one?

    self.title = albums.first
    self.year = years.first
    self.various_artists = artists.size > 1

    self.artists = artists.map do |artist_name|
      Artist.find_or_create_by_normalized_name(artist_name.to_slug.normalize.to_s, :name => artist_name)
    end

    true
  end

  def description_file
    Dir.glob(File.join(self.path, "*.nfo")).first
  end

  def playlist_uri
    "file://#{Dir.glob(File.join(self.path, "*.m3u")).first}"
  end

  def path_uri
    "file://#{self.path}"
  end

  def update_metadata
    response = Nestful.get("http://ws.audioscrobbler.com/2.0/", :format => :json, :params => {
        :api_key => "b25b959554ed76058ac220b7b2e0a026",
        :format => "json",
        :method => "album.getinfo",
        :artist => self.artists.map(&:name).join(" "),
        :album => self.title
    })

    if album = response["album"]
      update_attributes :mbid => album["mbid"],
                        :image_url => album["image"].last["#text"],
                        :lastfm_url => album["url"],
                        :listeners => album["listeners"],
                        :play_count => album["playcount"],
                        :released_at => (Date.parse(album["releasedate"].strip) rescue nil),
                        :year => (Date.parse(album["releasedate"].strip).year rescue self.year)
    end
    true
  end
end