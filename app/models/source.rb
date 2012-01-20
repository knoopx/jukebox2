class Source < ActiveRecord::Base
  validates_presence_of :path
  validates_uniqueness_of :path

  validate do
    errors.add :path, "does not exist" unless Dir.exist?(self.path)
  end
end
