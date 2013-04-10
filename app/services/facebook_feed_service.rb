module FacebookFeedService
  def self.publish_random_level
    level = Level.random()

    oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])

    # Get pages accounts of administrator (token of administrator is extended (https://developers.facebook.com/roadmap/offline-access-removal/))
    admin    = User.where(:f_id => ENV['FACEBOOK_ADMIN_ID']).first
    graph    = Koala::Facebook::API.new(admin.f_token)
    accounts = graph.get_connections(ENV['FACEBOOK_ADMIN_ID'], "accounts")

    # Get page token to publish on feed
    page_access_token = ""
    accounts.each do |account|
      if account['id'] == ENV['FACEBOOK_PAGE_ID']
        page_access_token = account['access_token']
        break
      end
    end

    # publish on feed
    page = Koala::Facebook::API.new(page_access_token)
    page.put_connections(ENV['FACEBOOK_PAGE_ID'], 'feed', :message => "I am writing on a page wall!")
  end
end

