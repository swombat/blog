require 'mongrel_cluster/recipes'

ssh_options[:username] = "dtenner"
ssh_options[:port] = 22

set :application, "inter-sections"
set :repository,  "git://github.com/swombat/blog.git"
default_run_options[:pty] = true
set :scm, "git"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

role :app, "www.inter-sections.net"
role :web, "www.inter-sections.net"
role :db,  "www.inter-sections.net", :primary => true

set :branch, "origin/master"

set :user, "dtenner"
set :runner, "dtenner"
set :spinner_user, "dtenner"

set :deploy_to, "/var/www/#{application}"
set :mongrel_conf, "/etc/mongrel_cluster/mongrel_cluster_intersections.yml"

desc "Link in the production database.yml"
task :after_update_code do
  run "rm -rf #{release_path}/config/database.yml"
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
end