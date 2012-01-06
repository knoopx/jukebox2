#= require jquery
#= require jquery_ujs
#= require jquery.pjax
#= require twitter/bootstrap
#= require_tree .
#= require_self

$ ->
    $.pjax.defaults.timeout = 30000
    $("a:not([data-play], [data-remote])").pjax "body > .container-fluid > .content"

    $('form[method=get]:not([data-remote])').live 'submit', (event) ->
      event.preventDefault()
      $.pjax
        container: "body > .container-fluid > .content"
        url: this.action + '?' + $(this).serialize()

    $("a[data-play]").live 'click', (e) ->
      e.preventDefault()
      AudioPlayer.playTracks($(this).attr("href"))

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

    $window = $(window)
    $playlist = $(".jp-playlist ul")
    $playlist.css("max-height", $window.height() - $playlist.offset().top - 10)
