# You need to create a file "/config/initializers/facebook.rb" with this :
# ENV['FACEBOOK_KEY'] = '11111111111111'
# ENV['FACEBOOK_SECRET'] = '1X1X1X1X1X1X1#X1X1X1X1X1X1X1X1X1X1X1'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
           :scope => 'email'
end
