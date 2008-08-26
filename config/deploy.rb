ssh_options[:username] = "dtenner"
ssh_options[:port] = 22

set :application, "inter-sections"
set :repository,  "git://github.com/swombat/blog.git"
default_run_options[:pty] = true
set :scm, "git"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

role :app, "swombat.sleektech.nl"
role :web, "swombat.sleektech.nl"
role :db,  "swombat.sleektech.nl", :primary => true

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

namespace :deploy do
  %w(start stop restart).each do |action| 
     desc "#{action} the Thin processes"  
     task action.to_sym do
       find_and_execute_task("thin:#{action}")
    end
  end 
end

namespace :thin do  
  %w(start stop restart).each do |action| 
  desc "#{action} the app's Thin Cluster"  
    task action.to_sym, :roles => :app do  
      run "thin #{action} -c #{deploy_to}/current -C #{deploy_to}/current/config/thin.yml" 
    end
  end
end

after "deploy", "deploy:cleanup"