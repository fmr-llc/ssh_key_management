# removes US crypto restrictions from Java runtime
if defined? JRUBY_VERSION
  java.lang.Class
    .for_name('javax.crypto.JceSecurity')
    .get_declared_field('isRestricted')
    .tap do |f|
      f.accessible = true
      f.set nil, false
    end
end

require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'coffee-rails' # gets rid of autoloading error during test runs
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SSHKeyManager
  # Main Class for app
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.sass.preferred_syntax = :sass
  end
end
