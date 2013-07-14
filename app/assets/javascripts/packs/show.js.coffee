#= require packs/show-history
#= require packs/show-facebook
#= require packs/show-level-thumb
#= require packs/show-invitation
#= require packs/show-scores
#= require packs/show-fullscreen

window.update_packs_select = ->
  level_count   = $('#levels li').length
  success_count = $('#levels li .s-icon-star').length

  pack_name = $('#packs').attr('data-pack-name')
  $('#packs select option:selected').text("#{pack_name} [#{success_count}/#{level_count}]")

$ ->
  # Initialize webgl and load selected level
  window.context = new Jax.Context({renderers: []})
  window.context.canvas = document.body
  window.context.setupInputDevices()
  window.context.redirectTo('level/index')

  # Scroll the left menu to the selected level
  level_button = $('#levels .is-selected')
  $('#levels').scrollTo(level_button, 1000, { easing:'swing', offset: -10 } )

  # Click on level (on packs/show)
  $('#levels li, #levels li a').live('click', ->
    $('#levels').find(".is-selected").removeClass('is-selected')
    $(this).closest('li').addClass('is-selected')

    # change the level (the '.is-selected' level is chosen)
    window.change_level()

    # change the url and save related state (pack and level)
    window.push_this_state()

    false
  )

  # Change level when select another level
  $('#packs select').on('change', ->
    pack_name = $('#packs select').val()
    location.assign("/packs/#{pack_name}")
  )

  $('#packs .packs-button a').on('click', ->
    window.colorbox_random_level()
    false
  )

  $('#pay-me-a-beer').on('click', ->
    window.colorbox_donation()
    false
  )

  $('#current-level-name h3').on('mouseenter', -> $('#current-level-description').fadeIn())
  $('#current-level-name h3').on('mouseleave', -> $('#current-level-description').stop().fadeOut())
  $('#current-level-name h3').trigger('mouseleave') # Avoid the fact that the description was hidden in CSS (maybe SEO impact ?)
