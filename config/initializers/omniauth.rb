# Rename the file "/config/initializers/facebook.rb.example" and adapt it

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
           :scope                  => ENV['FACEBOOK_SCOPE'],
           :provider_ignores_state => true,
           :secure_image_url       => true
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
