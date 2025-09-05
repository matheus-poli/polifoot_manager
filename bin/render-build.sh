#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
bundle install

# Precompile assets
bundle exec rails assets:precompile
bundle exec rails tailwindcss:build

# Database setup - single database for all solid gems
bundle exec rails db:create RAILS_ENV=production
bundle exec rails db:migrate RAILS_ENV=production