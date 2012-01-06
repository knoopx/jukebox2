@AudioPlayer =
  playTracks: (uri) ->
    AudioPlayer.getTracks uri, (tracks) ->
      Playlist.setPlaylist tracks.map (track) ->
        title: track.title, artist: track.artist, mp3: track.stream_uri

  enqueueTrack: (track) ->
    Playlist.add title: track.title, artist: track.artist, mp3: track.stream_uri

  getTracks: (uri, callback) ->
    $.getJSON uri, (response) -> callback(response)