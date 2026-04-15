# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby & Rails versions
    * Ruby 3.2.6 was used in development, but nothing outlandish was done with Ruby, so any recent version is probably fine.
    * Rails 8.1.3, but again, nothing crazy so any recent version should work.

* System dependencies
    * Only 3 gems were added to the Rails defaults: geokit-rails for Geocoding, open-weather-ruby-client for forecasting, and dotenv for secrets/API keys
    * Normally, checking secrets in to version control is bad form, but given the circumstance, I've checked two files in, one for development and one for testing (.env.local and .env.test)
    * Database is sqlite3, so no additional configuration is needed.  Not great for scaling up, but for the purposes of a demo project run locally, it's just fine.  Moving to Postgresql or MySQL with proper resources and support would be needed in production.

* Configuration
    * Pull the "main" branch to a local folder
    * cd to the local folder in a terminal
    * If you don't have Rails 8.x installed, run "gem install rails"
    * run "bundle install" to install the required gems for the project
    * Run "rails db:create", "rails db:migrate" and "rails db:seed" (or just rails db:setup).  This should create the database and seed a few addresses.
    * In a terminal, run "rails server" (add -pSOME_PORT_NUMBER if you want something besides localhost:3000
    * In a browser, load "http://localhost:3000" to get started.  You can click on one of the existing locations or add your own.

* How to run the test suite
    * run "rails test" to execute the test suite

* Services (job queues, cache servers, search engines, etc.)
    * This app uses three service objects to encapsulate and abstract Geocoding of locations (determining lat/lng and zip_code) and the, using that data, retrieving the current and extended forecasts for the location.

* Deployment instructions
    * Not intended for deployment at this time.
