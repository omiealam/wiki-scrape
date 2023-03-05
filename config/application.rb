require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WikiScrape
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    require 'cloudflare_proxy'
    config.middleware.use CloudflareProxy

    # allow cross origin requests
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :patch, :put, :delete]
      end
    end

    # background jobs
    config.active_job.queue_adapter = :delayed

    # mailers via postmark
    config.action_mailer.default_url_options = { host: ENV['base_url'] }
    config.action_mailer.default_options = { from: ENV['admin_email'] }
    config.action_mailer.delivery_method = :mailgun
    config.action_mailer.mailgun_settings = {
      api_key: ENV['mailgun_api_token'],
      domain: ENV['mailgun_domain']
    }

    # serve images from asset pipeline in mailers
    config.asset_host = ENV['base_url']

    # customize generators
    config.generators do |g|
      g.test_framework  :rspec, :fixture => false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.view_specs = false
      g.helper_specs = false
      g.assets = false # stylesheets
      g.helper = true
    end
  end
end
