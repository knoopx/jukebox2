class Tagging < ActiveRecord::Base
  belongs_to :genre
  belongs_to :artist
end
