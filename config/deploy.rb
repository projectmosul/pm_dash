# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'project_mosul_dash'
set :repo_url, 'git@github.com:projectmosul/pm_dash.git'

set :deploy_to, '/home/mosul/apps/projectmosul-dash'

set :passenger_restart_command, 'touch'
set :passenger_restart_options, -> { "#{deploy_to}/current/tmp/restart.txt" }

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('project-f22fdc45263f.p12', '.env', 'unicorn.rb')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end
