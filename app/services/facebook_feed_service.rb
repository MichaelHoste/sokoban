module FacebookFeedService
  def self.publish_random_level
    level = Level.random()

    oauth        = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])
    access_token = oauth.get_app_access_token
    graph        = Koala::Facebook::API.new(access_token)
    accounts     = graph.get_connections(ENV['FACEBOOK_ADMIN_ID'], "accounts")

    accounts.each do |account|
      if account['id'] == ENV['FACEBOOK_PAGE_ID']
        page_access_token = account['access_token']
        break
      end
    end

    page = Koala::Facebook::API.new(page_access_token)
    page.put_connections(ENV['FACEBOOK_PAGE_ID'], 'feed', :message => "I am writing on a page wall!")
  end
end
