import jQuery from 'jquery'
import 'popper.js'
import 'bootstrap/dist/js/bootstrap'
import Plyr from 'plyr'

jQuery(function() {
  const plyr = new Plyr('#video-main', {
    controls: [
      'play-large', // The large play button in the center
      'restart', // Restart playback
      'rewind', // Rewind by the seek time (default 10 seconds)
      'play', // Play/pause playback
      'fast-forward', // Fast forward by the seek time (default 10 seconds)
      'progress', // The progress bar and scrubber for playback and buffering
      'current-time', // The current time of playback
      'duration', // The full duration of the media
      'mute', // Toggle mute
      'volume', // Volume control
      'captions', // Toggle captions
      'settings', // Settings menu
      'pip', // Picture-in-picture (currently Safari only)
      'airplay', // Airplay (currently Safari only)
      'download', // Show a download button with a link to either the current source or a custom URL you specify in your options
      'fullscreen', // Toggle fullscreen
    ],
    disableContextMenu: false,
    keyboard: {
      focused: true,
      global: true,
    },
    tooltips: {
      controls: true,
      seek: true,
    },
  })
})

jQuery(function() {
  jQuery.ajax('/sources.json').done(function(sources) {
    var rssAtomButton = jQuery('#sources-button-rss-atom')
      .click(function() {
        switch (rssAtomButton.data('state')) {
          case 'enabled':
            rssAtomButton.data('state', 'disabled')
            break
          case 'disabled':
            rssAtomButton.data('state', 'none')
            break
          default:
            rssAtomButton.data('state', 'enabled')
            break
        }

        applyFilters()
      })
      .prop('disabled', false)

    var telegramButton = jQuery('#sources-button-telegram')
      .click(function() {
        switch (telegramButton.data('state')) {
          case 'enabled':
            telegramButton.data('state', 'disabled')
            break
          case 'disabled':
            telegramButton.data('state', 'none')
            break
          default:
            telegramButton.data('state', 'enabled')
            break
        }

        applyFilters()
      })
      .prop('disabled', false)

    var twitterButton = jQuery('#sources-button-twitter')
      .click(function() {
        switch (twitterButton.data('state')) {
          case 'enabled':
            twitterButton.data('state', 'disabled')
            break
          case 'disabled':
            twitterButton.data('state', 'none')
            break
          default:
            twitterButton.data('state', 'enabled')
            break
        }

        applyFilters()
      })
      .prop('disabled', false)

    function applyFilters() {
      var rssAtomButtonState  = null
      var telegramButtonState = null
      var twitterButtonState  = null

      rssAtomButton.removeClass('btn-primary')
      rssAtomButton.removeClass('btn-secondary')
      rssAtomButton.removeClass('btn-danger')

      telegramButton.removeClass('btn-primary')
      telegramButton.removeClass('btn-secondary')
      telegramButton.removeClass('btn-danger')

      twitterButton.removeClass('btn-primary')
      twitterButton.removeClass('btn-secondary')
      twitterButton.removeClass('btn-danger')

      switch (rssAtomButton.data('state')) {
        case 'enabled':
          rssAtomButtonState = 'enabled'
          rssAtomButton.addClass('btn-primary')
          break
        case 'disabled':
          rssAtomButtonState = 'disabled'
          rssAtomButton.addClass('btn-danger')
          break
        default:
          rssAtomButtonState = 'none'
          rssAtomButton.addClass('btn-secondary')
          break
      }

      switch (telegramButton.data('state')) {
        case 'enabled':
          telegramButtonState = 'enabled'
          telegramButton.addClass('btn-primary')
          break
        case 'disabled':
          telegramButtonState = 'disabled'
          telegramButton.addClass('btn-danger')
          break
        default:
          telegramButtonState = 'none'
          telegramButton.addClass('btn-secondary')
          break
      }

      switch (twitterButton.data('state')) {
        case 'enabled':
          twitterButtonState = 'enabled'
          twitterButton.addClass('btn-primary')
          break
        case 'disabled':
          twitterButtonState = 'disabled'
          twitterButton.addClass('btn-danger')
          break
        default:
          twitterButtonState = 'none'
          twitterButton.addClass('btn-secondary')
          break
      }

      var selectedSources = sources.filter(function(source) {
        var hasRssAtom  = false
        var hasTelegram = false
        var hasTwitter  = false

        source['links'].forEach(function(link) {
          if (link['title'] === 'RSS' || link['title'] === 'Atom') {
            hasRssAtom = true
          }

          if (link['title'] === 'Telegram') {
            hasTelegram = true
          }

          if (link['title'] === 'Twitter') {
            hasTwitter = true
          }
        })

        if (rssAtomButtonState === 'enabled'  && !hasRssAtom) return false
        if (rssAtomButtonState === 'disabled' && hasRssAtom)  return false

        if (telegramButtonState === 'enabled'  && !hasTelegram) return false
        if (telegramButtonState === 'disabled' && hasTelegram)  return false

        if (twitterButtonState === 'enabled'  && !hasTwitter) return false
        if (twitterButtonState === 'disabled' && hasTwitter) return false

        return true
      })

      var selectedSourceIds = selectedSources.map(function(selectedSource) {
        return selectedSource['id']
      })

      sources.forEach(function(source) {
        if (selectedSourceIds.includes(source['id'])) {
          jQuery('#source-' + source['id']).removeClass('d-none')
        }
        else {
          jQuery('#source-' + source['id']).addClass('d-none')
        }
      })
    }
  })
})
