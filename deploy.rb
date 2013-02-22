# Template Deployment recipe (Capistrano)

## basic setup stuff ##

# http://help.github.com/deploy-with-capistrano/
set :application, "Hermes" #the name of the application
set :repository, "git@github.com:Unicity/Deployment-System.git" #the url for the repo
set :scm, "git" #capistrano defaults to svn, we are telling it to use git
set :scm_username, "mygithubusername" #username for the git repo if you can anything with http auth
set :scm_passphrase, "mygithubpassword"  # The password for the user to log into the repo
default_run_options[:pty] = true # Must be set for the password prompt from git to work
set :deploy_to, "/var/www/application" # The directory in the remote server we will be deploying to... 
                                       # this is not where the web server is pointed
                                       # The web server would be pointed to :deploy_to/current

# use our keys, make sure we grab submodules, try to keep a remote cache
ssh_options[:forward_agent] = true # This is so that you dont have to have ssh keys in the remote server add to git, it will use the keys in the machine
                                   # you're deploying from
set :git_enable_submodules, 1 #self-explanatory, turn on git
set :deploy_via, :remote_cache #this is the best option, keeps a copy on the git repo on the remote server so when you deploy, it pulls a diff rather than a clone everytime
set :use_sudo, false #even though this is set to false, you still need passwordless sudo in the remote machine/s
set :copy_cache, true # speeds up deployments to multiple boxes... it does a check out on the first server copies that checkout and uses the copy on the next server

## multi-stage deploy process ###

# simple version @todo make db settings environment specific
# https://github.com/capistrano/capistrano/wiki/2.x-Multiple-Stages-Without-Multistage-Extension

task :dev do
  role :web, "127.0.0.1", :primary => true # For ruby deployments you have different roles, for our purposes, we just use web
  set :app_environment, "dev"
  set :user, "sshusername"
  set :password, "sshpassword"
  # this is so we automatically deploy current master, without tagging
  set :branch, "master" # for dev, just deploy the master branch
  #set :use_sudo, true # if you want commands ran with sudo, you need passwordless sudo
  #set :deploy_to, "/mnt/hgfs/apps/applicationdev" # you could change the deploy_to dir based on the environment
end

task :staging do
  role :web, "172.17.49.56", :primary => true
  set :user, "sshusername"
  set :password, "sshpassword"
  set :app_environment, "staging" #this is used in the task :finalize_update
                                  #and you can echo out a string to set an global var in your application to change the
                                  #configuration, take a look the example commented out
  # this is so we automatically deploy the latest numbered tag
  # (with staging releases we use incrementing build number tags) this looks for tags following this format: b1, b2, b3, etc
  set :branch, `git tag | xargs -I@ git log --format=format:"%ci %h @%n" -1 @ | sort | awk '{print  $5}' | egrep '^b[0-9]+$' | tail -n 1`
end

task :production do
  role :web, "172.17.49.55", :primary => true
 #role :web, "192.168.9.168" #here is how you would deploy to another prod server 
  set :user, "sshusername"
  set :password, "sshpassword"
  set :app_environment, "production"
end

## tag selection ##

# we will ask which tag to deploy; default = latest
# http://nathanhoad.net/deploy-from-a-git-tag-with-capistrano
set :branch do
  default_tag = `git describe --abbrev=0 --tags`.split("\n").last

  tag = Capistrano::CLI.ui.ask "Tag to deploy (make sure to push the tag first): [#{default_tag}] "
  tag = default_tag if tag.empty?
  tag
end unless exists?(:branch)

## php cruft ##

# https://github.com/mpasternacki/capistrano-documentation-support-files/raw/master/default-execution-path/Capistrano%20Execution%20Path.jpg
# https://github.com/namics/capistrano-php

namespace :deploy do

  task :finalize_update, :except => { :no_release => true } do
    transaction do
      run "chmod -R g+w #{releases_path}/#{release_name}"
      # change the environment configuration
      #run "echo '#{app_environment}' > #{releases_path}/#{release_name}/config/environment.txt"
      #do unit testing
      #run "cd #{releases_path}/#{release_name} && phing build"
    end
  end

  task :migrate do
    # do nothing
  end

  task :restart, :except => { :no_release => true } do
    # reload apache or whatever the web server is
    run "sudo service apache2 reload" #the reason for passwordless sudo
  end

  after "deploy", :except => { :no_release => true } do
    # an example for doing unit testing after the deployment is done
   # run "cd #{releases_path}/#{release_name} && phing spawn-workers > /dev/null 2>&1 &", :pty => false
  end
end
