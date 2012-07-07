require 'spec_helper'

describe Artist do
  context "#merge_with" do
    let!(:artist_one) do
      Artist.create!(
          :name => "Artist 1",
          :mbid => "mbid-1",
          :tags_array => ["hardcore", "punk"],
          :normalized_name => "artist-1",
          :releases => [Release.new(:name => "Release 1")],
          :favorited_at => 1.day.ago
      )
    end

    let!(:artist_two) do
      Artist.create!(
          :name => "Artist 2",
          :mbid => "mbid-2",
          :tags_array => ["hardcore", "screamo"],
          :normalized_name => "artist-2",
          :releases => [Release.new(:name => "Release 2")],
          :favorited_at => 2.day.ago
      )
    end

    example do
      artist_one.releases.size.should == 1
      artist_two.releases.size.should == 1

      artist_one.merge_with(artist_two)

      artist_one.releases.size.should == 2
      artist_one.tags_array.should == ["hardcore", "punk", "screamo"]
      artist_one.favorited_at.should == artist_two.favorited_at
      artist_one.mbids.should be_include(artist_two.mbid)

      lambda { artist_two.reload }.should raise_exception(Mongoid::Errors::DocumentNotFound)
    end
  end
end