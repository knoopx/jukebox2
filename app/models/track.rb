class Track < ActiveRecord::Base
  belongs_to :release
  belongs_to :artist

  def full_path
    File.join(release.path, filename)
  end

  def file_uri
    "file://#{full_path}"
  end
end
