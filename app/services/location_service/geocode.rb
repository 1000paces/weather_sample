# frozen_string_literal: true

# Service Object Class to accept a Location object's id and
# determine its latitude, longitude and zip_code
# Also preserves the JSON response from the
# Geocoder for error handling
module LocationService
  class Geocode
    # Gem to abstract use of Geocoder. We are using Google's
    include Geokit::Geocoders

    # Loads the @object, in this case a Location record
    # when the class is instantiated
    def initialize(id:)
      @object = Location.find_by_id(id)
    end

    # Class version of call
    # Instantiates class and calls #call
    def self.call(id:)
      new(id: id).call
    end

    # Instance version of call
    # Determines lat/lng
    # Determins zip_code
    # Reloads and returns Location object
    # to requester
    def call
      determine_lat_lng
      determine_zip_code

      @object.reload
    end

    private

    # Uses GoogleGeocoder to determine lat/lng for an
    # address or address fragment
    # Updates given Location with the data
    def determine_lat_lng
      loc = Geokit::Geocoders::GoogleGeocoder.geocode(@object.address)
      if loc.success
        @object.update(latitude: loc.latitude,
                       longitude: loc.longitude,
                       geolocation: loc.to_json)
      else
        # In case of failure, records the result so
        # requester can handle it.
        @object.update(geolocation: loc.to_json)
      end
    end

    # Reverse Geocodes using the new lat/lng to get
    # zip_code (used to connect Location and Forecast
    # objects)
    def determine_zip_code
      return if @object.latitude.nil? || @object.longitude.nil?

      res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode([ @object.latitude, @object.longitude ])
      if res.success
        @object.update(zip_code: res.zip)
      end
    end
  end
end
