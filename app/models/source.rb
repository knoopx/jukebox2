class Source < ActiveRecord::Base
  validates_presence_of :path
  validates_uniqueness_of :path
end
