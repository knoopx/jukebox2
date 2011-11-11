@AudioPlayer =
  init: ->
    @initUI()

  initUI: ->
    @container = $("#player")

    @information = $("#player .info")
    @artistName = $("#player .info .artist")
    @trackTitle = $("#player .info .track")
    @progressBar = $("#player .progress-bar")
    @seekBar = $("#player .seek-bar")
    @bufferBar = $("#player .buffer-bar")
    @timeBar = $("#player .time-bar")
    @playButton = $("#player .buttons .play")
    @skipButton = $("#player .buttons .skip")

    @playButton.text "Play"
    @skipButton.text "Skip"
    @artistName.text "Unknown Artist"
    @trackTitle.text "Unknown Track"

    @playButton.click @togglePlay
    @skipButton.click @skipTrack
    @seekBar.click (e) ->
      AudioPlayer.currentStream.setPosition e.offsetX / $(this).width() * AudioPlayer.currentStream.duration
      e.preventDefault()

    @container.hide()

  playTrack: (trackId) ->
    soundManager.stopAll()
    @getTrack trackId, (track) ->
      soundManager.destroySound track.id
      $(".track").removeClass "playing"
      $("#track_" + track.id).addClass "playing"
      AudioPlayer.currentTrack = track
      AudioPlayer.artistName.text track.artist
      AudioPlayer.trackTitle.text track.title
      @document.title = track.artist + " - " + track.title

      AudioPlayer.currentStream = soundManager.createSound(
        id: track.id
        url: "/tracks/" + track.id + "/play"
        onplay: AudioPlayer.resumePlayback
        onresume: AudioPlayer.resumePlayback
        onpause: AudioPlayer.stopPlayback
        onstop: AudioPlayer.stopPlayback
        whileloading: AudioPlayer.updateLoadProgress
        whileplaying: AudioPlayer.updatePosition
        onfinish: AudioPlayer.skipTrack
      )
      soundManager.play track.id

    @container.show()

  playTracks: (trackIds) ->
    @setMode "playlist"
    @playlist = trackIds
    @playTrack @playlist[0]

  getTrack: (trackId, callback) ->
    $.getJSON "/tracks/" + trackId, (track) ->
      callback track

  resumePlayback: ->
    AudioPlayer.playButton.text "Pause"

  stopPlayback: ->
    AudioPlayer.playButton.text "Play"

  updatePosition: ->
    AudioPlayer.timeBar.width (@position / @duration * 100) + "%"

  togglePlay: (e) ->
    soundManager.togglePause AudioPlayer.currentTrack.id
    e.preventDefault()

  updateLoadProgress: ->
    AudioPlayer.bufferBar.width (@bytesLoaded / @bytesTotal * 100) + "%"

  setMode: (mode) ->
    switch mode
      when "playlist"
        AudioPlayer.mode = "playlist"
        return
      when "endless"
        AudioPlayer.mode = "endless"

  skipTrack: ->
    switch AudioPlayer.mode
      when "playlist"
        index = $(AudioPlayer.playlist).index(AudioPlayer.currentTrack.id)
        nextIndex = index + 1
        AudioPlayer.playTrack AudioPlayer.playlist[nextIndex] if nextIndex < AudioPlayer.playlist.length
        return