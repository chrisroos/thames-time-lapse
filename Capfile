require 'recap/recipes/rails'

set :application, 'thames-time-lapse'
set :repository, 'git@github.com:chrisroos/thames-time-lapse.git'

server 'thames-time-lapse.chrisroos.co.uk', :app

task :update_crontab do
  as_app 'bundle exec whenever --update-crontab'
end

after :deploy, :update_crontab
