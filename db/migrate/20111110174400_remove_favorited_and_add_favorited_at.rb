class RemoveFavoritedAndAddFavoritedAt < ActiveRecord::Migration
  def up

    add_column :artists, :favorited_at, :datetime
    add_column :releases, :favorited_at, :datetime

    [Artist, Release].each do |klass|
      favorited = klass.where(:favorited => true)
      favorited.update_all(:favorited_at => DateTime.now)
    end

    remove_column :artists, :favorited
    remove_column :releases, :favorited
  end

  def down
  end
end
