# config valid only for current version of Capistrano
lock '3.4.0'

set :application, Rails.application.class.parent_name.underscore
set :repo_url, ENV['REPO_URL']

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, "/usr/share/nginx/apps/#{fetch :application}"

set :user, 'deployer'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

set :log_level, :info

# Default value for :pty is false
# set :pty, true
dotenv_files = Dir.glob('.env*')
linked_files = dotenv_files + %w(config/database.yml config/secrets.yml config/ldap.yml config/ldap_extra.yml)
set :linked_files, fetch(:linked_files, []) + linked_files

linked_dirs = %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads)
set :linked_dirs, fetch(:linked_dirs, []) + linked_dirs

set :assets_roles, [:web, :app]

# set :default_env, 'rvmsudo_secure_path' => '0'

# Default value for keep_releases is 5
# set :keep_releases, 5

# Needed since we:
# 1. develop on windows machines with a different Gemfile.lock
# 2. push changes
# 2a. bad build in jenkins because Gemfile.lock is missing
# 3. ssh to linux box
# 4. pull changes
# 5. generate new Gemfile.lock
# 6. push that back up
# 7. jenkins builds app and deploys
set :bundle_flags, '--quiet'

# Currently Passenger 5.x needs sudo to restart the app instance see https://github.com/phusion/passenger/issues/1392
# set :passenger_restart_command, 'rvmsudo passenger-config restart-app'

set :conditionally_migrate, true

namespace :deploy do
  before 'deploy:check:linked_files', 'linked_files:upload'
end
