#= require jquery
#= require jquery_ujs
#= require jquery.pjax
#= require soundmanager2
#= require twitter/bootstrap
#= require_tree .
#= require_self

soundManager.url = "/swf/"
soundManager.flashVersion = 9
soundManager.useFlashBlock = false
soundManager.onready ->
  AudioPlayer.init()

$ ->
    $.pjax.defaults.timeout = 30000
    $("a:not([data-play-tracks], [data-play-artist], [data-remote])").pjax "body > .container > .content"

    $('form[method=get]:not([data-remote])').live 'submit', (event) ->
      event.preventDefault()
      $.pjax
        container: "body > .container > .content"
        url: this.action + '?' + $(this).serialize()

    $("a[data-play-artist]").live 'click', (e) ->
      e.preventDefault()
      artist_id = $(this).data("play-artist")
      tracks = $.getJSON "/tracks", { artist_id: artist_id }, (response) ->
        AudioPlayer.playTracks($.map(response, (item) -> item.id))

    $("a[data-play-tracks]").live 'click', (e) ->
      e.preventDefault()
      AudioPlayer.playTracks($(this).data("play-tracks"))

