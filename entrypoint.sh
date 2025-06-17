#!/bin/bash
set -e

until pg_isready -h db -U postgres; do
  echo "Waiting database"
  sleep 1
done

bundle exec rails db:prepare

exec "$@"
