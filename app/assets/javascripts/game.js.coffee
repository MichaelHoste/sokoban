$ ->  
  populate_packs()
  
  $("#packs li").live('click', ->
    $(this).parent().find(".is-selected").removeClass("is-selected")
    $(this).addClass("is-selected")
    populate_levels($(this).text())
  )
  
  $("#levels li").live('click', ->
    $(this).parent().find(".is-selected").removeClass("is-selected")
    $(this).addClass("is-selected")
    delete window.context
    window.context = new Jax.Context('webgl')
    window.context.redirectTo("level")
  )
  
  $("#packs li:first").addClass("is-selected")
  populate_levels($("#packs li:first").text())
  $("#levels li:first").addClass("is-selected")
  window.context = new Jax.Context('webgl')
  window.context.redirectTo("level")
  
populate_packs = ->
  packs =
    [
      "Original"
      "100Boxes"
      "81"
      "ALDMGR"
      "AlbertoG-Best4U"
      "AlbertoG1-1"
      "AlbertoG1-2"
      "AlbertoG1-3"
      "Albizia"
      "Aruba10"
      "Aruba2"
      "Aruba3"
      "Aruba4"
      "Aruba5"
      "Aruba6"
      "Aruba7"
      "Aruba8"
      "Aruba9"
      "Aruba_eric"
      "AutoGen"
      "Boxxle1"
      "Boxxle2"
      "Calx"
      "Cosmac"
      "Cosmac2"
      "Cosmac3"
      "Cosmac4"
      "Dimitri-Yorick"
      "Erim"
      "Essai"
      "Fly"
      "GabyJenny"
      "Handmade"
      "HeyTak"
      "Ian01"
      "Jct"
      "Kepez"
      "Kokoban"
      "Loma"
      "MarioB"
      "MasterHead"
      "MicroCosmos"
      "MiniCosmos"
      "Monde"
      "NaboCosmos"
      "Novoban"
      "Numbers"
      "Patera"
      "PicoCosmos"
      "RBox_Levels"
      "SQA-File"
      "Serena1"
      "Serena2"
      "Serena3"
      "Serena4"
      "Serena5"
      "Serena6"
      "Serena7"
      "Serena8"
      "Serena9"
      "Sharpen"
      "Simple"
      "SokEvo"
      "SokHard"
      "Sokoban_Online"
      "Sokolate"
      "Sokomania"
      "Sokompact"
      "Soloban"
      "Spirals"
      "StillMore"
      "Sven"
      "TBox_2"
      "TBox_3"
      "TBox_4"
      "Takaken"
      "TitleScreens"
      "Twisty"
      "YASGood"
      "aenigma"
      "bagatelle"
      "bagatelle2"
      "cantrip"
      "cantrip2"
      "dh1"
      "dh2"
      "dur01dnd"
      "fpok"
      "grigr2001"
      "grigr2002"
      "howard1text"
      "howard2text"
      "howard3text"
      "howard4text"
      "jcd"
      "maelstrm"
      "masmicroban"
      "massasquatch"
      "microban"
      "sasquatch"
      "sasquatchiii"
      "sasquatchiv"
      "sasquatchv"
      "sasquatchvi"
      "sasquatchvii"
      "sokogen-990602"
    ]
    
  for pack in packs
    $("#packs").append("<li>" + pack + "</li>")
    
populate_levels = (pack) ->
  $("#levels").text(" ")
  
  $.ajax({
    type:     "GET",
    url:      "/levels/" + pack + ".slc",
    dataType: "xml",
    success:  get_level_list
    async:    false
    context:  @
  })
  
get_level_list = (xml) ->
  levels = $(xml).find('Level')
  
  for level in levels
    $("#levels").append("<li>" + $(level).attr("Id") + "</li>")
