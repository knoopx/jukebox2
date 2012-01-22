class Track
  include Mongoid::Document
  include Mongoid::Timestamps
  include Jukebox2::Search::Scope
  include Jukebox2::Favorites::ModelMethods
  include Mongoid::CounterCache

  field :filename
  field :number, :type => Integer
  field :title
  field :sample_rate
  field :bitrate
  field :channels
  field :length
  field :year
  field :length
  field :favorited_at, :type => DateTime
  field :local_play_count, :type => Integer, :default => 0

  belongs_to :artist
  belongs_to :release

  counter_cache :name => :artist, :inverse_of => :tracks
  counter_cache :name => :release, :inverse_of => :tracks

  scope :title_or_artist_name_or_release_name_like, lambda { |query|
    any_of(:title => /#{query}/i, :artist_name => /#{query}/i, :release_name => /#{query}/i)
  }
  search_scope :title_or_artist_name_or_release_name_like

  def full_path
    File.join(release.path, filename)
  end

  def file_uri
    "file://#{full_path}"
  end
end
