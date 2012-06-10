MODE = "production"
PRODUCTION_SERVER = "fallingfoundry.com"
STAGING_SERVER = "fallinggarden.com"
SERVER = MODE == "production" ? PRODUCTION_SERVER : STAGING_SERVER


$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
 require 'bundler/capistrano'
 require 'rvm/capistrano'
server SERVER, :web, :db, :app, primary: true
set :user, "root"
set :application, "FayeServer"

set :deploy_to, "/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, true

set :scm, "git"
set :repository,  "git://github.com/HungryAcademyTeam4/FayeServer.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true



namespace :deploy do
  task :mkdirs do
    run "mkdir /apps/#{application}/releases/current -p"
    run "mkdir /apps/god_scripts -p"
  end
  task :start do
    run "cd /apps/#{application}/current && bundle install --system"
    run "cd /apps/#{application}/current && ./start.sh"
  end
  before "deploy", "deploy:mkdirs"
  after "deploy", "deploy:start"
end