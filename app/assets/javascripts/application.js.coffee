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
      wmode: "window"
    )
