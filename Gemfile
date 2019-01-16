source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0.2'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'sidekiq', '~> 5.2.1'

# gem 'smarter_csv', '~> 1.2.3'
gem 'smarter_csv', git: 'https://github.com/brindu/smarter_csv.git', branch: 'multiline_option'
gem 'activerecord-import'

gem 'trailblazer', '~> 2.1.0.rc1'
gem 'trailblazer-rails'
gem 'dry-validation', '~> 0.11.1'

gem 'prawn'
gem 'prawn-table'
gem 'sentry-raven'

# ELK bridge
gem 'logstasher'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', require: 'rack/cors'

group :development, :test do
  gem 'awesome_print'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'spring-commands-rspec'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'shoulda-matchers'
  gem 'guard-rspec'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pdf-inspector'
  gem 'pry'
  gem 'pry-byebug'
  gem 'timecop'
  gem 'mimemagic'
  gem 'unindent'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'colorize'
  gem 'mina', '~> 1.2.3'
end
