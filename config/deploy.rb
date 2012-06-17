MODE = ENV["DEPLOY_MODE"] || "production"

PRODUCTION_SERVER = "fallingfoundry.com"
STAGING_SERVER = "fallinggarden.com"
APPLICATION_NAME = "FayeServer"
SCRIPT_NAME = "faye"
REPOSITORY = "git://github.com/HungryAcademyTeam4/FayeServer.git"
SERVER = MODE == "production" ? PRODUCTION_SERVER : STAGING_SERVER
START_COMMAND = 'cd /apps/FayeServer/current \&\& thin start -e production -p 9000 -D -l \/faye_main.log'

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
server SERVER, :web, :db, :app, primary: true
set :user, "root"
set :application, APPLICATION_NAME

set :deploy_to, "/apps/#{application}"
set :deploy_via, :remote_cache

set :scm, "git"
set :repository, REPOSITORY
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
  task :mkdirs do
    run "mkdir /apps/#{application}/releases/current -p"
    run "mkdir /apps/god_scripts -p"
  end
  task :create_god_script do
    run %^cd /apps/god_scripts && touch #{SCRIPT_NAME}.rb && rm #{SCRIPT_NAME}.rb && touch #{SCRIPT_NAME}.rb^
    run %^echo God.watch do \\\|w\\\| >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
    run %^echo w.log = \\\"/#{SCRIPT_NAME}.log\\\" >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
    run %^echo w.name = \\\"#{SCRIPT_NAME}\\\" >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
    run %^echo w.start = \\\"#{START_COMMAND}\\\" >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
    run %^echo w.keepalive >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
    run %^echo end >> /apps/god_scripts/#{SCRIPT_NAME}.rb^
  end
  task :bundle do
    run "cd /apps/#{application}/current && bundle install --system"
  end
  task :start do
    run "cd / && god"
    run "cd / && god load apps/god_scripts/#{SCRIPT_NAME}.rb"
    run "cd / && god start #{SCRIPT_NAME}"
  end
  task :stop do
    run "cd / && god stop #{SCRIPT_NAME}"
  end
  task :restart do
    stop
    start
  end
  task :ensure_god_running do
    run "cd / && god"
  end
  before "deploy:start", "deploy:ensure_god_running"
  before "deploy:stop", "deploy:ensure_god_running"
  before "deploy", "deploy:mkdirs"
  before "deploy", "deploy:create_god_script"
  after "deploy", "deploy:bundle"
  after "deploy", "deploy:start"
end