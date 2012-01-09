@AudioPlayer =
  playTracks: (uri) ->
    AudioPlayer.getTracks uri, (tracks) ->
      Playlist.setPlaylist(tracks)

  enqueueTrack: (track) ->
    Playlist.add(track)

  getTracks: (uri, callback) ->
    $.getJSON uri, (response) -> callback(response)