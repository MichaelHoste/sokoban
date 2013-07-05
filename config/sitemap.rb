# regenerate sitemap with 'rake sitemap:refresh'

SitemapGenerator::Sitemap.default_host = "https://sokoban-game.com"

SitemapGenerator::Sitemap.create do
  add '/privacy_policy'
  add '/terms_of_service'
  add '/rankings'

  Level.all.each do |level|
    add pack_level_path(level.pack, level)
  end

  User.registered.each do |user|
    add user_path(user)
  end
end
