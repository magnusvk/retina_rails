ENV['RAILS_ENV'] = 'test'

require "sprockets/railtie"

module RetinaRailsTest
  class Application < Rails::Application
    config.active_support.deprecation = :log

    config.assets.manifest = Rails.public_path.to_s.gsub('public', 'spec/fixtures')

    ## Asset config

    config.assets.version      = '1.0'
    config.serve_static_assets = false
    config.assets.enabled      = true
    config.assets.compress     = true
    config.assets.compile      = false
    config.assets.digest       = true

    # Rails 4 will raise an error if we don't define this
    config.secret_token        = SecureRandom.hex(30)
  end
end
RetinaRailsTest::Application.initialize!
