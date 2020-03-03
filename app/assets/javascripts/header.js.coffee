$ ->
  $('#menus .rules-menu').on('click', ->
    window.colorbox_welcome()
  )

  $('#menus .ranking-menu, #menus .ranking-position').on('click', ->
    location.assign($(this).find('a').attr('href'))
  )

  # Open login in popup => https://stackoverflow.com/questions/4491433/turn-omniauth-facebook-login-into-a-popup
  $('#menus .fb-login').on('click', (e) ->
    width  = 600
    height = 400
    left   = (screen.width/2)-(width/2)
    top    = (screen.height/2)-(height/2)
    url    = $(this).find('a').attr("href")

    window.open(url + '?close_popup=true', "authPopup", "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top)

    e.stopPropagation()
    return false
  )

  # close popup once logged!
  if window.opener && $('body').data('close-popup') == 'true'
    window.opener.location.reload(true)
    window.close()

  # Show logout only if not on facebook canvas
  # http://blog.blakesimpson.co.uk/read/22-detect-if-page-is-within-facebook-iframe-or-not-javascript
#  if window.name == ''
#    $('#menus .logout').show()
#    $('#menus .logout').css('display', 'inline-block')

  # initialize and change theme
  window.theme = "classic"
