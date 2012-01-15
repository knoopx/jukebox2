#= require jquery
#= require jquery_ujs
#= require jquery.pjax
#= require_tree .
#= require_self

$ ->
    $.pjax.defaults.timeout = 30000
    $("a:not([data-play], [data-enqueue], [data-remote])").pjax "body > .container > .content"

    $('form[method=get]:not([data-remote])').live 'submit', (event) ->
      event.preventDefault()
      $.pjax
        container: "body > .container > .content"
        url: this.action + '?' + $(this).serialize()

    $("a[data-play]").live 'click', (e) ->
      e.preventDefault()
      AudioPlayer.playTracks($(this).attr("href"))

    $("a[data-enqueue]").live 'click', (e) ->
      e.preventDefault()
      AudioPlayer.enqueueTracks($(this).attr("href"))

    originalTitle = document.title
    $favicon = $("link[rel='shortcut icon']");


    window.Playlist = new jPlayerPlaylist(
      jPlayer: "#jquery_jplayer",
      cssSelectorAncestor: "#jp_container",
      [],
      playlistOptions:
        autoPlay: true,
        enableRemoveControls: true
      ,
      swfPath: "/swf/",
      supplied: "mp3",
      wmode: "window",

      playing: (e) ->
        media = e.jPlayer.status.media
        $favicon.attr("href", "/assets/play.ico")
        document.title = media.artist + " - " + media.title
        $currentTitle = $(e.jPlayer.options.cssSelectorAncestor + " .jp-current-title")
        $currentArtist = $(e.jPlayer.options.cssSelectorAncestor + " .jp-current-artist")
        $currentRelease = $(e.jPlayer.options.cssSelectorAncestor + " .jp-current-release")
        $currentArtwork = $(e.jPlayer.options.cssSelectorAncestor + " .jp-current-artwork")
        $currentTitle.text(media.title)
        $currentRelease.html($("<a>", href: media.release_url).text(media.release))
        $currentArtist.html($("<a>", href: media.artist_url).text(media.artist))
        $currentArtwork.css("background-image", "url(" + media.release_images.medium + ")")

      pause: ->
        document.title = originalTitle
        $favicon.attr("href", "/assets/favicon.ico")

      ended: ->
        document.title = originalTitle
        $favicon.attr("href", "/assets/favicon.ico")
    )
