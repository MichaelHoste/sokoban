namespace :app  do
  namespace :stats  do
    task :number_of_moves => :environment do
      moves = LevelUserLink.sum(:moves)
      puts "#{moves} moves"
    end

    task :number_of_pushes => :environment do
      pushes = LevelUserLink.sum(:pushes)
      puts "#{pushes} pushes"
    end

    task :number_of_hours => :environment do
      moves = LevelUserLink.sum(:moves)
      hours = (moves / 5.0) / 3600.0

      puts "#{hours.round(2)} hours"
    end

    task :number_of_days => :environment do
      moves = LevelUserLink.sum(:moves)
      hours = (moves / 5.0) / 3600.0
      days  = hours / 24.0

      puts "#{days.round(2)} days"
    end
  end
end


