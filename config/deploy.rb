# config valid only for current version of Capistrano
lock '3.6.0'

set :application, 'deploy_test'
set :repo_url, 'git@github.com:Ericean/deploy_test.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/deploy/deploy_test'



set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs) + %w{public/uploads}
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

set :config_dirs, %W{config config/environments/#{fetch(:stage)} public/uploads}
set :config_files, %w{config/database.yml config/secrets.yml}

namespace :deploy do
  desc 'Copy files from application to shared directory'
  ## copy the files to the shared directories
  task :config do
    on roles(:app) do
      # create dirs
      fetch(:config_dirs).each do |dirname|
        path = File.join shared_path, dirname
        execute "mkdir -p #{path}"
      end

      # copy config files
      fetch(:config_files).each do |filename|
        remote_path = File.join shared_path, filename
        upload! filename, remote_path
      end

    end
  end
end

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end