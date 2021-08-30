require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sokojax
  class Application < Rails::Application
    config.time_zone           = 'UTC'
    config.i18n.default_locale = :en
    config.active_record.raise_in_transactional_callbacks = true

    #ActiveRecordQueryTrace.enabled = true
  end
end
