#!/bin/sh

set -e

### install gem files.

bundle install --path vendor/bundle

### create secret.yml and application_settings.yml from template file

bundle exec rake dtb:install

### migrate DB

bundle exec rake db:migrate
bundle exec rake db:migrate RAILS_ENV=production

### Initialize DB

bundle exec rake db:seed_fu
bundle exec rake db:seed_fu RAILS_ENV=production

### Install submodules

git submodule init
git submodule update
