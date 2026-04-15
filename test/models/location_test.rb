require "test_helper"

class LocationTest < ActiveSupport::TestCase
  setup do
    @loc = Location.create(address: "Boston, MA",
                           zip_code: "02110",
                           latitude: 0.423555076e2,
                           longitude: -0.710565364e2,
                           geolocation: "{\"success\":true,\"lat\":42.3555076,\"lng\":-71.0565364,\"country_code\":\"US\",\"city\":\"Boston\",\"county\":\"Suffolk County\",\"state\":\"MA\",\"zip\":null,\"street_address\":null,\"district\":\"Suffolk County\",\"provider\":\"google\",\"full_address\":\"Boston, MA, USA\",\"is_us?\":true,\"ll\":\"42.3555076,-71.0565364\",\"precision\":\"city\",\"district_fips\":null,\"state_fips\":null,\"block_fips\":null,\"sub_premise\":null}")

    @fore = Forecast.create(zip_code: "02110")
  end

  test "association with forecast" do
    assert_equal @fore.id, @loc.forecast.id
    assert_equal @loc.id, @fore.locations.first.id
  end

  test "validates address presence" do
    loc = Location.new
    assert_equal false, loc.valid?

    loc.address = "1234 Main Street"
    loc.save

    assert_equal true, loc.valid?
  end

  test "retrieves latest forecast and verifies cache status" do
    Rails.cache.delete("#{@loc.zip_code}_forecast")
    assert_equal @loc.zip_code, @loc.forecast.zip_code

    forecast = @loc.latest_forecast_cached
    assert_equal false, forecast.from_cache
    assert_equal @loc.zip_code, @loc.forecast.zip_code

    forecast = @loc.latest_forecast_cached
    assert_equal true, forecast.from_cache
  end

  test "clears cached forecast" do
    assert_not_nil @loc.latest_forecast_cached
    forecast = @loc.latest_forecast_cached
    assert_equal true, forecast.from_cache

    @loc.clear_cached_forecast
    assert_equal false, @loc.latest_forecast_cached.from_cache
  end

  test "evaluates geocoding" do
    assert_equal false, @loc.failed?

    bad_loc = Location.create(address: "junk")
    assert_equal true, bad_loc.failed?
  end
end
