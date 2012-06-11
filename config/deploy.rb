MODE = "production"
PRODUCTION_SERVER = "fallingfoundry.com"
STAGING_SERVER = "fallinggarden.com"
SERVER = MODE == "production" ? PRODUCTION_SERVER : STAGING_SERVER


$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# require 'bundler/capistrano'
 require 'rvm/capistrano'
server SERVER, :web, :db, :app, primary: true
set :user, "root"
set :application, "FayeServer"

#set :bundle_dir, "/apps/#{application}/current"
#set :bundle_flags, "--deployment --quiet --system"

set :deploy_to, "/apps/#{application}"
set :deploy_via, :remote_cache

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
  task :create_god_script do
    run 'cd /apps/god_scripts && touch faye.rb && rm faye.rb && touch faye.rb'
    run 'echo God.watch do \|w\| >> /apps/god_scripts/faye.rb'
    run 'echo w.log = \"/faye.log\" >> /apps/god_scripts/faye.rb'
    run 'echo w.name = \"faye\" >> /apps/god_scripts/faye.rb'
    run 'echo w.start = \"rainbows /apps/FayeServer/current/faye.ru -c /apps/FayeServer/current/rainbows.conf -E production -p 9000\"  >> /apps/god_scripts/faye.rb'
    run 'echo w.keepalive >> /apps/god_scripts/faye.rb'
    run 'echo end >> /apps/god_scripts/faye.rb'
  end
  task :bundle do
    run "cd /apps/#{application}/current && bundle install --system"
  end
  task :start do
    run "cd / && god"
    run "cd / && god load apps/god_scripts/faye.rb"
    run "cd / && god start faye"
  end
  before "deploy", "deploy:mkdirs"
  before "deploy", "deploy:create_god_script"
  after "deploy", "deploy:bundle"
  after "deploy", "deploy:start"
end