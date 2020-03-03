$ ->
  $('#menus .rules-menu').on('click', ->
    window.colorbox_welcome()
  )

  $('#menus .ranking-menu, #menus .ranking-position').on('click', ->
    location.assign($(this).find('a').attr('href'))
  )

  $('#menus .fb-login').on('click', (e) ->
    # on canvas ! https://blog.blakesimpson.co.uk/page.php?id=22&title=detect-if-page-is-within-facebook-iframe-or-not-javascript
    # Open login in popup => https://stackoverflow.com/questions/4491433/turn-omniauth-facebook-login-into-a-popup
    if window.name.indexOf('iframe_canvas_fb') > -1
      width  = 1000
      height = 700
      left   = (screen.width/2)-(width/2)
      top    = (screen.height/2)-(height/2)
      url    = $(this).find('a').attr("href")

      window.open(url + '?close_popup=true', "authPopup", "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top)

      e.stopPropagation()
      return false
    else
      # on website
      location.assign($(this).find('a').attr('href'))
  )

  # close popup once logged!
  if window.opener && $('body').attr('data-close-popup') == 'true'
    #window.opener.location.reload(true)
    location.assign($("#menus .fb-login a").attr('href'))
    window.close()

  # Show logout only if not on facebook canvas
  # http://blog.blakesimpson.co.uk/read/22-detect-if-page-is-within-facebook-iframe-or-not-javascript
#  if window.name == ''
#    $('#menus .logout').show()
#    $('#menus .logout').css('display', 'inline-block')

  # initialize and change theme
  window.theme = "classic"
