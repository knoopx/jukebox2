class Track < ActiveRecord::Base
  belongs_to :release, :counter_cache => true
  belongs_to :artist, :counter_cache => true

  def full_path
    File.join(release.path, filename)
  end

  def file_uri
    "file://#{full_path}"
  end
end
