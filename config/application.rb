require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RncsWorkerApiEntreprise
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults '6.0'

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '/v1/fiches_identite/*', headers: :any, methods: [:get]
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.time_zone = 'Paris'
    config.i18n.default_locale = 'fr-FR'

    config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_name_prefix = "rncs_worker_api_entreprise_#{Rails.env}"

    # TODO watch out about this !
    # Stock units are run concurently, but independant from each other, so we
    # shouldn't have any issue with concurrent updates.
    # It may improves import speed though. I keep this until I have a better
    # knowledge of the data quality. Uncomment when ready
    # config.active_record.lock_optimistically = false

    config.generators do |g|
        g.orm :active_record, primary_key_type: :uuid
    end

    config.rncs_sources = config_for(:rncs_sources)
    config.rncs_sources_path = ::File.join(Rails.configuration.rncs_sources['local_path_prefix'], Rails.configuration.rncs_sources['ftp_path_prefix'])
  end
end
