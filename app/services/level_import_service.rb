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
          new_level = pack.levels.create!({ :name       => level['Id'].strip,
                                            :width      => level['Width'].strip.to_i,
                                            :height     => level['Height'].strip.to_i,
                                            :copyright  => (level.has_attribute?('Copyright') ? level['Copyright'].strip : ''),
                                            :grid       => grid,
                                            :won_count  => 0 })

          core_level = Core::Level.new(grid.join("\n"))

          new_level.grid_with_floor = core_level.grid.join.scan(/.{#{core_level.cols}}/)
          new_level.boxes_number    = core_level.boxes
          new_level.goals_number    = core_level.goals
          new_level.pusher_pos_m    = core_level.pusher[:pos_m]
          new_level.pusher_pos_n    = core_level.pusher[:pos_n]
          new_level.complexity      = core_level.cols * core_level.rows * core_level.boxes
          new_level.save!
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

