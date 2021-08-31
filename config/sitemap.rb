# regenerate sitemap with 'rake sitemap:refresh'

SitemapGenerator::Sitemap.default_host = "https://sokoban-game.com"

SitemapGenerator::Sitemap.create do
  add '/terms_of_service', :priority => 1.0
  add '/privacy_policy',   :priority => 1.0
  add '/packs',            :priority => 1.0
  add '/rankings',         :priority => 1.0
  add '/master_thesis',    :priority => 0.5

  Pack.all.each do |pack|
    add pack_path(pack), :priority => 1.0
  end

  Pack.all.each do |pack|
    add download_pack_path(pack)
  end

  Level.all.each do |level|
    add pack_level_path(level.pack, level), :priority => 0.5
  end

  User.registered.each do |user|
    add user_path(user), :priority => 0.75
  end
end
