# regenerate sitemap with 'rake sitemap:refresh'

SitemapGenerator::Sitemap.default_host = "https://sokoban-game.com"

SitemapGenerator::Sitemap.create do
  add '/terms_of_service'
  add '/privacy_policy'
  add '/packs'
  add '/rankings'

  Pack.all.each do |pack|
    add pack_path(pack)
  end

  Pack.all.each do |pack|
    add download_pack_path(pack)
  end

  Level.all.each do |level|
    add pack_level_path(level.pack, level)
  end

  User.registered.each do |user|
    add user_path(user)
  end
end
