#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
bundle install

# Precompile assets
bundle exec rails assets:precompile
bundle exec rails tailwindcss:build

# Database setup for Render Blueprint
# Create databases for all solid gems
bundle exec rails db:create RAILS_ENV=production

# Run migrations for primary database
bundle exec rails db:migrate RAILS_ENV=production

# Run migrations for solid gems databases
bundle exec rails db:migrate:cache RAILS_ENV=production
bundle exec rails db:migrate:queue RAILS_ENV=production  
bundle exec rails db:migrate:cable RAILS_ENV=production