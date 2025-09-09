#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready
echo "Waiting for database..."
until pg_isready -h db -p 5432 -U postgres -q; do
  sleep 1
done

echo "Database is ready!"

# Run database setup
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rails db:migrate
else
  bundle exec rails db:create db:migrate
fi

# Execute the container's main process
exec "$@"