$ ->
  # link of the big facebook button
  # Open login in popup => https://stackoverflow.com/questions/4491433/turn-omniauth-facebook-login-into-a-popup
  $('#session .session-button').on('click', (e) ->
    #location.assign($('.session-connect a').attr('href'))

    width  = 600
    height = 400
    left   = (screen.width/2)-(width/2)
    top    = (screen.height/2)-(height/2)
    url    = $(this).find('a').attr("href")

    window.open(url + '?close_popup=true', "authPopup", "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top)

    e.stopPropagation()
    return false
  )

