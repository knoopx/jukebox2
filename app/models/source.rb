class Source < ActiveRecord::Base
  validates_uniqueness_of :path
end
