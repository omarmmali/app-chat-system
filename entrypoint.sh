#!/usr/bin/env bash
bin/rake db:migrate
bin/rake db:migrate RAILS_ENV=test
rm -f tmp/pids/server.pid
bin/rails server -b 0.0.0.0 -p $APPLICATION_PORT
