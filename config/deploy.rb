# require 'capistrano/ext/multistage'

set :application, "voice_guestbook"
set :repository,  "git@github.com:hlxwell/Voice-Guestbook.git"
set :branch, ENV["BRANCH"] || "master"
set :deploy_to, "/home/hlx/www/voice_guestbook/"
set :user, "hlx"
set :use_sudo, false
set :rails_env, "production"
set :scm, "git"

role :web, "bbs.hzva.org"                          # Your HTTP server, Apache/etc
role :app, "bbs.hzva.org"                          # This may be the same as your `Web` server
role :db,  "bbs.hzva.org", :primary => true        # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :init_project do
    run "cd #{release_path}; /home/hlx/.rvm/gems/ree-1.8.7-2010.01/bin/bundle install"
    run "ln -s #{shared_path}/ckeditor_assets #{release_path}/public/ckeditor_assets"
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

before "deploy:symlink", "deploy:init_project"