require_relative "boot"

require "rails/all"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AltamaCitadel
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.autoload_paths << "#{Rails.root}/lib"
    # Configuration for the application, engines, and railties goes here.
    
    #added for commodity constants
    config.autoload_paths += %W(#{config.root}/lib)

#pineapple
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '/shipments/json_request',
                 headers: :any,
                 methods: [:post]
        resource '/ship_components',
                  headers: :any,
                  methods: [:get, :post]
      end
    end

    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
