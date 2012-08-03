# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

require 'v8'

puts ENV['RAILS_ENV']

packs_production = [
                      "100Boxes",
                      "81",
                      "ALDMGR",
                      "AlbertoG-Best4U",
                      "AlbertoG1-1",
                      "AlbertoG1-2",
                      "AlbertoG1-3",
                      "Albizia",
                      "Aruba10",
                      "Aruba2",
                      "Aruba3",
                      "Aruba4",
                      "Aruba5",
                      "Aruba6",
                      "Aruba7",
                      "Aruba8",
                      "Aruba9",
                      "Aruba_eric",
                      "AutoGen",
                      "Boxxle1",
                      "Boxxle2",
                      "Calx",
                      "Cosmac",
                      "Cosmac2",
                      "Cosmac3",
                      "Cosmac4",
                      "Dimitri-Yorick",
                      "Erim",
                      "Essai",
                      "Fly",
                      "GabyJenny",
                      "Handmade",
                      "HeyTak",
                      "Ian01",
                      "Jct",
                      "Kepez",
                      "Kokoban",
                      "Loma",
                      "MarioB",
                      "MasterHead",
                      "MicroCosmos",
                      "MiniCosmos",
                      "Monde",
                      "NaboCosmos",
                      "Novoban",
                      "Numbers",
                      "Original",
                      "Patera",
                      "PicoCosmos",
                      "RBox_Levels",
                      "SQA-File",
                      "Serena1",
                      "Serena2",
                      "Serena3",
                      "Serena4",
                      "Serena5",
                      "Serena6",
                      "Serena7",
                      "Serena8",
                      "Serena9",
                      "Sharpen",
                      "Simple",
                      "SokEvo",
                      "SokHard",
                      "Sokoban_Online",
                      "Sokolate",
                      "Sokomania",
                      "Sokompact",
                      "Soloban",
                      "Spirals",
                      "StillMore",
                      "Sven",
                      "TBox_2",
                      "TBox_3",
                      "TBox_4",
                      "Takaken",
                      "TitleScreens",
                      "Twisty",
                      "YASGood",
                      "aenigma",
                      "bagatelle",
                      "bagatelle2",
                      "cantrip",
                      "cantrip2",
                      "dh1",
                      "dh2",
                      "dur01dnd",
                      "fpok",
                      "grigr2001",
                      "grigr2002",
                      "howard1text",
                      "howard2text",
                      "howard3text",
                      "howard4text",
                      "jcd",
                      "maelstrm",
                      "masmicroban",
                      "massasquatch",
                      "microban",
                      "sasquatch",
                      "sasquatchiii",
                      "sasquatchiv",
                      "sasquatchv",
                      "sasquatchvi",
                      "sasquatchvii",
                      "sokogen-990602"
                   ]

packs_development =  ['Original', 'Novoban']

#if Rails.env == 'development'
#  packs = packs_development
#elsif Rails.env == 'production'
  packs = packs_production
#end

# populate levels from
def populate_levels(packs)
  # loop on each pack
  packs.each do |pack_file|
    puts "Import level pack : #{pack_file}.slc"

    # Open pack file
    File.open("lib/assets/levels/#{pack_file}.slc", 'r') do |f|
      xml_doc = Nokogiri::XML(f)
      
      # save pack informations
      pack = Pack.create!({ :file_name   => pack_file,
                            :name        => xml_doc.css('SokobanLevels > Title').text().strip,
                            :description => xml_doc.css('SokobanLevels > Description').text().strip,
                            :email       => xml_doc.css('SokobanLevels > Email').text().strip,
                            :url         => xml_doc.css('SokobanLevels > Url').text().strip,
                            :copyright   => xml_doc.css('LevelCollection').first['Copyright'].strip,
                            :max_width   => xml_doc.css('LevelCollection').first['MaxWidth'].strip.to_i,
                            :max_height  => xml_doc.css('LevelCollection').first['MaxHeight'].strip.to_i })

      # loop on each level
      levels = xml_doc.css('LevelCollection > Level')
      levels.each do |level|
        puts '  * level name : ' + level['Id'].strip
        
        # create the grid of the level (array with 1 string = 1 row )
        grid = []
        level.css('L').each do |line|
          grid << line.text
        end

        # save level information
        new_level = pack.levels.create!({ :name      => level['Id'].strip,
                                          :width     => level['Width'].strip.to_i,
                                          :height    => level['Height'].strip.to_i,
                                          :copyright => (level.has_attribute?('Copyright') ? level['Copyright'].strip : ''),
                                          :grid      => grid })
        
        # Import the level to javascript, compute the floor and some useful datas
        # and then get back the new grid from javascript to save it to the database
        V8::C::Locker() do
          V8::Context.new do |cxt|
            cxt.eval('var window = new Object')
            cxt.load('lib/assets/level_core.js')
            cxt.eval('var lines = new Array')
            grid.each_with_index do |line, i|
              cxt.eval("lines[#{i}]  = '#{line}'")
            end
          
            cxt.eval('var level = new window.LevelCore()')
            cxt.eval("level.create_from_grid(lines, #{new_level.width}, #{new_level.height}, \"#{pack.name}\", \"#{new_level.name}\", \"#{new_level.copyright}\")")
          
            new_level.grid_with_floor = Array.new
            (0..new_level.height-1).each do |i|
              line = ""
              (0..new_level.width-1).each do |j|
                letter = cxt.eval("level.grid[#{i*new_level.width+j}]")
                line = line + (letter ? letter : ' ')
                new_level.grid_with_floor[i] = line
              end
            end
            new_level.boxes_number = cxt.eval("level.boxes_number")
            new_level.goals_number = cxt.eval("level.goals_number")
            new_level.pusher_pos_m = cxt.eval("level.pusher_pos_m")
            new_level.pusher_pos_n = cxt.eval("level.pusher_pos_n")
            new_level.save!
          end
        end
        # for garbage collector purposes
        V8::C::V8::IdleNotification()
      end # end of levels
      puts ""
    end # end of fopen pack
  end # end of packs loop
end

populate_levels(packs)

# LEVEL THUMBS ARE GENERATED THE FIRST TIME THEY ARE USED

#def create_level_thumbs
#  (1..Level.count).to_a.each do |level_id|
#    Level.find(level_id).generate_thumb
#  end
#end

#create_level_thumbs()



