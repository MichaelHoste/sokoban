# Rename the file "/config/initializers/facebook.rb.example" and adapt it

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['SOKOBAN_FACEBOOK_KEY'], ENV['SOKOBAN_FACEBOOK_SECRET'],
           :scope => 'email, publish_actions'
end
