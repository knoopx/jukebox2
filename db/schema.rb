# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111110174400) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "artists", :force => true do |t|
    t.string   "name"
    t.string   "normalized_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mbid"
    t.string   "lastfm_url"
    t.integer  "listeners",       :default => 0
    t.integer  "play_count",      :default => 0
    t.string   "image_url"
    t.text     "summary"
    t.text     "biography"
    t.text     "similar_mbids"
    t.datetime "favorited_at"
  end

  create_table "artists_releases", :id => false, :force => true do |t|
    t.integer "artist_id"
    t.integer "release_id"
  end

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "releases", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "path"
    t.string   "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "various_artists", :default => false
    t.string   "mbid"
    t.string   "image_url"
    t.string   "lastfm_url"
    t.string   "listeners"
    t.integer  "play_count",      :default => 0
    t.text     "summary"
    t.text     "review"
    t.date     "released_at"
    t.datetime "favorited_at"
  end

  create_table "sources", :force => true do |t|
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :id => false, :force => true do |t|
    t.integer "artist_id"
    t.integer "genre_id"
    t.integer "id"
  end

  add_index "taggings", ["artist_id", "genre_id"], :name => "index_taggings_on_artist_id_and_genre_id"
  add_index "taggings", ["artist_id"], :name => "index_taggings_on_artist_id"
  add_index "taggings", ["genre_id"], :name => "index_taggings_on_genre_id"

  create_table "tracks", :force => true do |t|
    t.integer  "number"
    t.string   "title"
    t.string   "sample_rate"
    t.string   "bitrate"
    t.string   "channels"
    t.string   "length"
    t.string   "filename"
    t.integer  "release_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "year"
    t.integer  "artist_id"
    t.integer  "local_play_count", :default => 0
  end

end
