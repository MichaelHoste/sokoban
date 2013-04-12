require 'v8'

module LevelImportService
  def self.populate
    packs = []
    Dir.foreach('lib/assets/levels') do |item|
      next if item == '.' or item == '..' or item == 'SokobanLev.dtd'
      packs << item
    end

    # loop on each pack
    packs.each do |pack_file|
      puts "Import level pack : #{pack_file}"

      # Open pack file
      File.open("lib/assets/levels/#{pack_file}", 'r') do |f|
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

    puts "Generation of level thumbs (this can take some time)"

    Level.all.each do |level|
      level.generate_thumb
    end
  end
end

