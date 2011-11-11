class Genre < ActiveRecord::Base
  has_many :taggings
  has_many :artists, :through => :taggings

  scope :with_counts, select("genres.id, genres.name, COUNT(*) AS artists_count").joins(:artists.outer).
      group("genres.id, genres.name").
      having("artists_count > 0").
      order("artists_count DESC")

  scope :top, lambda { |limit|
    with_counts.limit(limit)
  }
end
