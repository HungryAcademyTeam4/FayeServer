MODE = "staging"
PRODUCTION_SERVER = "fallingfoundry.com"
STAGING_SERVER = "fallinggarden.com"
SERVER = MODE == "production" ? PRODUCTION_SERVER : STAGING_SERVER


$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
 require 'bundler/capistrano'
 require 'rvm/capistrano'
server SERVER, :web, :db, :app, primary: true
set :user, "deployer"
set :application, "FayeServer"

set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, true

set :scm, "git"
set :repository,  "git://github.com/HungryAcademyTeam4/Authbot.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true



namespace :deploy do
  task :start do   
    run "cd /home/#{user}/apps/#{application}/current && ./start.sh"
  end
  after "deploy", "deploy:start"
end