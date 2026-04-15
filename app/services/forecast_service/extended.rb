# frozen_string_literal: true

module ForecastService
  class Extended
    OPENWEATHERMAP_URI="https://api.openweathermap.org/data/2.5/forecast".freeze

    def initialize(id:)
      @location = Location.find_by(id: id)
      @forecast = @location.forecast
    end

    # Helper method so the object is more portable
    def self.call(id:)
      new(id: id).call
    end

    def call
      # Call the forecasting API and update the location's forecast
      current_forecast

      # Return the updated object
      @forecast.reload
    end

    private

    # Creates a new @client object using the API key
    def build_uri
      URI(OPENWEATHERMAP_URI)
    end

    def query_uri
      uri = build_uri
      uri.query = URI.encode_www_form(lat: @location.latitude, lon: @location.longitude, units: "imperial", appid: ENV["OPENWEATHER_API_KEY"])

      uri
    end

    # Uses the query_uri object to query the API for a specific location's forecast
    def current_forecast
      data = JSON.parse(Net::HTTP.get(query_uri))
      @forecast.update(extended: data)
    end
  end
end
