# frozen_string_literal: true

module ForecastService
  class Current
    def initialize(id:)
      @location = Location.find_by(id: id)
      @forecast = @location.forecast
    end

    # Helper method so the object is more portable
    def self.call(id:)
      new(id: id).call
    end

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
    def current_weather
      data = @client.current_weather(lat: @location.latitude, lon: @location.longitude, units: "imperial")

      @forecast.update(current: data)
    end
  end
end
