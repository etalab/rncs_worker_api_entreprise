Sidekiq.configure_server do |config|
  schedule_file = 'config/schedule.yml'

  if File.exists?(schedule_file)
    loaded_conf = YAML.load_file(schedule_file)
    Sidekiq::Cron::Job.load_from_hash(loaded_conf[Rails.env])
  end
end
