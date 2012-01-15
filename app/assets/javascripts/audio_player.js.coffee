@AudioPlayer =
  playTracks: (uri) ->
    AudioPlayer.getTracks uri, (tracks) ->
      Playlist.setPlaylist(tracks)

  enqueueTracks: (uri) ->
    AudioPlayer.getTracks uri, (tracks) ->
      $(tracks).each ->
        AudioPlayer.enqueueTrack(this)

  enqueueTrack: (track) ->
    Playlist.add(track)

  getTracks: (uri, callback) ->
    $.getJSON uri, (response) -> callback(response)