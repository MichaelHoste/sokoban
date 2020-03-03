$ ->
  # link of the big facebook button
  $('#session .session-button').on('click', (e) ->
    # on canvas ! https://blog.blakesimpson.co.uk/page.php?id=22&title=detect-if-page-is-within-facebook-iframe-or-not-javascript
    # Open login in popup => https://stackoverflow.com/questions/4491433/turn-omniauth-facebook-login-into-a-popup
    if window.name.indexOf('iframe_canvas_fb') > -1
      width  = 600
      height = 400
      left   = (screen.width/2)-(width/2)
      top    = (screen.height/2)-(height/2)
      url    = $(this).find('.session-connect a').attr("href")

      window.open(url + '?close_popup=true', "authPopup", "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top)

      e.stopPropagation()
      return false
    else
      # on website
      location.assign($('.session-connect a').attr('href'))
  )

