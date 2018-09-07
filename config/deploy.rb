require 'mina/rails'
require 'mina/bundler'
require 'colorize'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)

ENV['to'] ||= 'sandbox'
%w[sandbox production].include?(ENV['to']) || raise("target environment (#{ENV['to']}) not in the list")
#
# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, 'rncs_api'
set :domain, 'ns3107905.ip-54-37-87.eu'
set :deploy_to, "/var/www/rncs_api_#{ENV['to']}"
set :rails_env, ENV['to']
set :repository, 'git@github.com:etalab/rncs_worker_api_entreprise.git'

# TODO configure for production environment
branch = ENV['branch'] ||
  begin
    case ENV['to']
    when 'sandbox'
      'master'
    end
  end

set :branch, branch
ensure!(:branch)

# Optional settings:
set :user, 'deploy'          # Username in the server to SSH to.
set :port, 22                # SSH port number.
set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`

set :shared_dirs, fetch(:shared_dirs, []).push(
  'bin',
  'log',
  'tmp/pids',
  'tmp/sockets',
  'tmp/cache',
)

set :shared_files, fetch(:shared_files, []).push(
  'config/database.yml',
  "config/environments/#{ENV['to']}.rb",
  'config/rncs_sources.yml',
  'config/sidekiq.yml',
  'config/master.key'
)

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  set :rbenv_path, '/usr/local/rbenv'
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0 --skip-existing}

  # add tc_stock log subfolder
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/log/tc_stock")
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        invoke :sidekiq
        invoke :passenger
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task :sidekiq do
  comment 'Restarting Sidekiq (reloads code)'.green
  command %(sudo systemctl restart sidekiq_rncs_api_#{ENV['to']}_1)
  command %(sudo systemctl restart sidekiq_rncs_api_#{ENV['to']}_2)
  command %(sudo systemctl restart sidekiq_rncs_api_#{ENV['to']}_3)
end

task :passenger do
  comment %{Attempting to start the app through passenger}.green
  command %{
    if (sudo passenger-status | grep rncs_api_#{ENV['to']}) > /dev/null
    then
      passenger-config restart-app /var/www/rncs_api_#{ENV['to']}/current
    else
      echo 'Skipping: no Passenger app found (will be automatically loaded)'
    fi}
end
