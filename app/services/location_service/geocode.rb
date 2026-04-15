# frozen_string_literal: true

# Class to accept a Location object's id and
# determine its latitude and longitude
# Also preserves the JSON response from the
# Geocoder for error handling
module LocationService
  class Geocode
    include Geokit::Geocoders

    def initialize(id:)
      @object = Location.find_by_id(id)
    end

    def self.call(id:)
      new(id: id).call
    end

    def call
      determine_lat_lng
      determine_zip_code

      @object.reload
    end

    private

    def determine_lat_lng
      loc = Geokit::Geocoders::GoogleGeocoder.geocode(@object.address)
      if loc.success
        @object.update(latitude: loc.latitude,
                       longitude: loc.longitude,
                       geolocation: loc.to_json)
      else
        @object.update(geolocation: loc.to_json)
      end
    end

    def determine_zip_code
      return if @object.latitude.nil? || @object.longitude.nil?

      res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode([ @object.latitude, @object.longitude ])
      if res.success
        @object.update(zip_code: res.zip)
      end
    end
  end
end
