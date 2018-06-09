#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

echo "Waiting for Postgres to start..."
if [[ "${RAILS_ENV}" = "production" ]]; then
  while ! nc -z production-postgres 5432; do sleep 0.1; done
else
  while ! nc -z db 5432; do sleep 0.1; done
fi
echo "Postgres is up"

if [ "$1" = "server" ]; then
  echo "preparing database..."
  rails db:exists && rails db:migrate || rails db:setup
  echo "database ready, starting server"
  bundle exec rails s -p 3000 -b 0.0.0.0
else
  exec "$@"
fi