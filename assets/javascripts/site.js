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
    jQuery('#sources-button-rss-atom')
      .click(function() {
        var selectedSources = []

        if (jQuery(this).hasClass('btn-outline-primary')) {
          jQuery(this).removeClass('btn-outline-primary')
          jQuery(this).addClass('btn-primary')

          selectedSources = sources.filter(function(source) {
            var links = source['links'].filter(function(link) {
              return link['title'] === 'RSS' || link['title'] === 'Atom'
            })

            return links.length > 0
          })
        }
        else {
          jQuery(this).removeClass('btn-primary')
          jQuery(this).addClass('btn-outline-primary')

          selectedSources = sources
        }

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
      })
      .prop('disabled', false)
  })
})
