#!/bin/bash

set -e

rm -f /cardeons/tmp/pids/server.pid

if [ "$SERVICE" == "web" ]; then
  rake db:create
  rake db:migrate
  rails db:seed cards=cards
  rails db:seed users=users
fi

exec "$@"