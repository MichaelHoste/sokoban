# Rename the file "/config/initializers/facebook.rb.example" and adapt it

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
           :scope            => 'email, publish_actions',
           :secure_image_url => true
end
