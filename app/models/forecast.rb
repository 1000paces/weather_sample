# Class to orgranize, process and store the weather
# data.
class Forecast < ApplicationRecord
  # Many locations/addresses share the same zip_code,
  # So I took the unusual step of using that to join the
  # Location and Forecast models, rather than a standard
  # foreign key.  Makes the caching more practical, given
  # that requirement.
  has_many :locations,
           foreign_key: :zip_code,
           primary_key: :zip_code,
           inverse_of: :forecast

  # Non persisted flag to indicate cache hits
  attr_accessor :from_cache

  # Callback to set default flag value
  after_find :record_cached

  # Method to bundle the weather data for display
  # Uses OpenStruct to behave like ActiveRecord
  # in the views.
  def data
    OpenStruct.new({
      current: current_weather,
      extended: tabular_forecast,
      sun: sun
    })
  end

  # Method to extract and organize the current weather
  # from the JSON returned by the API
  def current_weather
    OpenStruct.new({
      conditions: current&.dig("weather", 0, "main"),
      description: current&.dig("weather", 0, "description"),
      temp: current&.dig("main", "temp"),
      feels_like: current&.dig("main", "feels_like"),
      max_temp: current&.dig("main", "temp_max"),
      min_temp: current&.dig("main", "temp_min")
    })
  end

  # Method to extract and organize the extended forecast
  # from the JSON returned by the API
  def five_day_forecast
    list = extended&.dig("list")
    days = []
    list&.each do |day|
      days << OpenStruct.new({
        date: day["dt_txt"],
        day: Time.at(day["dt"])&.strftime("%A"),
        time: Time.at(day["dt"])&.strftime("%I:%M:%S %p"),
        conditions: day.dig("weather", 0, "main"),
        description: day.dig("weather", 0, "description"),
        temp: day.dig("main", "temp"),
        feels_like: day.dig("main", "feels_like"),
        max_temp: day.dig("main", "temp_max"),
        min_temp: day.dig("main", "temp_min")
      })
    end

    days
  end

  # Bonus sunrise/sunset data from API
  # Uses localtime for time zone weirdness
  def sun
    sunrise = current&.dig("sys", "sunrise")
    sunset = current&.dig("sys", "sunset")
    return OpenStruct.new({ rise: nil, set: nil }) if sunrise.nil? || sunset.nil?

    OpenStruct.new({
      rise: Time.zone.parse(sunrise)&.localtime&.strftime("%I:%M %p"),
      set: Time.zone.parse(sunset)&.localtime&.strftime("%I:%M %p")
    })
  end

  # def cached(zip_code)
  #   cache_key = "#{zip_code}_location"
  #   id = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
  #     Location.find_by(zip_code: zip_code).id
  #   end
  #   loc = Location.find_by(id: id)
  #   loc.from_cache = true

  #   loc
  # end

  # Method to organize the extended forecast data in a tabular
  # fashion for disply in a table. Used to reduce view
  # complexity.
  def tabular_forecast
    fdf = five_day_forecast
    days = fdf.map(&:day).uniq
    times = fdf.map(&:time).uniq
    sorted_times = times.sort_by { |t| Time.parse(t) }
    by_time_and_day = fdf.group_by(&:time).transform_values { |entries| entries.index_by(&:day) }

    { days: days, times: sorted_times, data: by_time_and_day }
  end

  private

  # Sets default cache hit flag value
  def record_cached
    self.from_cache = false
  end
end
