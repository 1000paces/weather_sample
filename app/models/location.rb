require "json"
require "ostruct" # convenience converting from hashes

class Location < ApplicationRecord
  acts_as_mappable

  # Related Forecast objects.  Using :destroy_async in
  # a background job  would scale better, but unneeded
  # for this sample project
  belongs_to :forecast,
             foreign_key: :zip_code,
             primary_key: :zip_code,
             inverse_of: :locations,
             optional: true

  # Requires an address to work
  validates :address, presence: true

  # Clears the cache when deleting a Location
  # assuming no more Location records exist for the
  # zip_code
  before_destroy :clear_cached_forecast

  def clear_cached_forecast
    return if Location.where(zip_code: zip_code).count > 1

    Rails.cache.delete("#{zip_code}_forecast")
  end

  # Get the most recent Forecast for the given Location (zip_code)
  # Also sets a flag to indicate cache hits vs. database/API hits
  def latest_forecast
    fc = forecast

    if fc.nil? ||
       fc.updated_at < 30.minutes.ago ||
       fc.current.nil? ||
       fc.extended.nil?
      fc = Forecast.find_or_create_by(zip_code: self.zip_code)
      query_forecast
      fc.reload
      fc.from_cache = false
      fc
    else
      fc.from_cache = true
      fc
    end
  end

  # Returns the cached version of a forecast, expiring in 30 minutes
  # Also sets a cache hit flag
  def latest_forecast_cached
    cache_hit = true
    zip = Rails.cache.fetch("#{zip_code}_forecast", expires_in: 30.minutes) do
      cache_hit = false
      latest_forecast.zip_code
    end
    forecast = Forecast.find_by(zip_code: zip)
    forecast.from_cache = cache_hit
    forecast
  end

  # Checks for failed geolocation
  def failed?
    return true if geolocation.nil? || latitude.nil? || longitude.nil?
    return true if JSON.parse(geolocation)&.dig("success") == false

    false
  end

  # Geocodes the current Location record using
  # a service object
  def geocode
    LocationService::Geocode.call(id: id)
    reload
  end

  # Queries the current weather using a service
  # object assuming the Location is valid
  def query_current
    return if geolocation.nil?
    return if JSON.parse(geolocation).dig("success") == false

    ForecastService::Current.call(id: id)
  end

  # Queries the extended forecast using a service object
  # assuming the Location is valid
  def query_extended
    return if geolocation.nil?
    return if JSON.parse(geolocation).dig("success") == false

    ForecastService::Extended.call(id: id)
  end

  # Helper method to query both current weather
  # and extended forecast
  def query_forecast
    query_current
    query_extended
  end
end
