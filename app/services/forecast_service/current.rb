# frozen_string_literal: true

# Service Object to retrieve the current weather
# for a given Location
module ForecastService
  class Current
    # Initializes the object, retrieving both the
    # Location via the id, and the Forecast via
    # the zip_code association
    def initialize(id:)
      @location = Location.find_by(id: id)
      @forecast = @location.forecast
    end

    # Class version of call
    def self.call(id:)
      new(id: id).call
    end

    # Instance version of call
    def call
      # Initialize a new OpenWeather Client
      client

      # Call the forecasting API and update the location's current weather
      current_weather

      # Return the updated object
      @forecast.reload
    end

    private

    # Creates a new @client object using the API key
    def client
      @client = OpenWeather::Client.new(api_key: ENV["OPENWEATHER_API_KEY"])
    end

    # Uses the @client object to query the API for a specific location
    # and update the Forecast::current field with the retrieved JSON
    def current_weather
      data = @client.current_weather(lat: @location.latitude, lon: @location.longitude, units: "imperial")

      @forecast.update(current: data)
    end
  end
end
