ssh_options[:username] = "daniel"
ssh_options[:port] = 12222

set :application, "inter-sections"
set :repository,  "git://github.com/swombat/blog.git"
default_run_options[:pty] = true
set :scm, "git"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

role :app, "linode.swombat.com"
role :web, "linode.swombat.com"
role :db,  "linode.swombat.com", :primary => true

set :branch, "master"

set :user, "daniel"
set :runner, "daniel"
set :spinner_user, "daniel"

set :deploy_to, "/data/#{application}"

desc "Link in the production database.yml"
task :after_update_code do
  run "rm -rf #{release_path}/config/database.yml"
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
  run "mkdir -p #{release_path}/tmp/cache"
end

set :keep_releases,     5
 
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
