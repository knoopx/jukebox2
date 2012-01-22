class TracksController < InheritedResources::Base
  include Jukebox2::Favorites::ControllerMethods

  belongs_to :artist, :optional => true
  belongs_to :release, :optional => true

  set_default_sort_attribute :number

  apply_filtering
  apply_sorting
  apply_search
  apply_pagination :unless => lambda { parent? }

  def show
    respond_to do |format|
      format.json do
        render :json => [
            {
                :title => resource.title,
                :artist => resource.artist.name,
                :artist_url => artist_url(resource.artist),
                :release => resource.release.title,
                :release_url => release_url(resource.release),
                :release_images => resource.release.images,
                :mp3 => play_track_url(resource)}
        ]
      end
    end
  end

  def index
    respond_to do |format|
      format.html { index! }
      format.json do
        response = collection.map do |resource|
          {
              :title => resource.title,
              :artist => resource.artist.name,
              :artist_url => artist_url(resource.artist),
              :release => resource.release.title,
              :release_url => release_url(resource.release),
              :release_images => resource.release.images,
              :mp3 => play_track_url(resource)
          }
        end
        render :json => response
      end
    end
  end

  def play
    resource.inc(:local_play_count, 1)
    file_path = resource.full_path
    length = File.size(file_path)
    status_code = 200
    range_start = 0
    range_end = length - 1

    headers.update(
        'Content-Type' => "application/octet-stream",
        'Content-Transfer-Encoding' => 'binary'
    )

    if request.env['HTTP_RANGE'] =~ /bytes=(\d+)-(\d*)/
      status_code = 206
      range_start, range_end = $1, $2

      if range_start.empty? and range_end.empty?
        headers["Content-Length"] = 0
        return render(:status => 416, :nothing => true)
      end

      if range_end.empty?
        range_end = length - 1
      else
        range_end = range_end.to_i
      end

      if range_start.empty?
        range_start = length - range_end
        range_end = length - 1
      else
        range_start = range_start.to_i
      end

      headers['Accept-Ranges'] = 'bytes'
      headers['Content-Range'] = "bytes #{range_start}-#{range_end}/#{length}"
    end

    range_length = range_end.to_i - range_start.to_i + 1
    headers['Content-Length'] = range_length.to_s
    headers['Cache-Control'] = 'private' if headers['Cache-Control'] == 'no-cache'

    File.open(file_path, 'rb') do |file|
      file.seek(range_start, IO::SEEK_SET)
      render :status => status_code, :text => file.read(range_length)
    end
  end
end