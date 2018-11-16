Raven.configure do |config|
  config.dsn = Rails.application.credentials.url_sentry
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  # TODO: remove sandbox when first version is deployed.
  # but we want data until then
  config.environments = %w[production sandbox]
end
