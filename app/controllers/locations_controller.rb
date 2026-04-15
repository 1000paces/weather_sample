# frozen_string_literal: true

# Controller for Location CRUD operations
# following Rails' REST/resources pattern
class LocationsController < ApplicationController
  # Showing the most recent 10 locations only. A production app
  # would implement search and/or pagination
  def index
    @locations = Location.order(updated_at: :desc).limit(10)
  end

  # Shows the current and extended forecast assuming
  # the Location record is valid and successfully
  # geocoded.
  def show
    @location = Location.find(params[:id])

    unless @location.failed?
      @forecast = @location.latest_forecast_cached
      # Helper variables to make the view code a little
      # clearer
      @current = @forecast.data.current
      @extended = @forecast.data.extended
      @sun = @forecast.data.sun
    end
  end

  # Action for adding a new Location
  def new
    @location = Location.new
  end

  # Action for creating Location.
  # If save is successful, geocodes and creates Forecast
  # if needed. Current and Extended service objects are
  # also queried
  def create
    @location = Location.new(location_params)
    if @location.save
      @location.geocode
      Forecast.find_or_create_by(zip_code: @location.zip_code)
      @location.query_forecast
      @location.clear_cached_forecast

      redirect_to @location
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Action for editing an existing Location
  def edit
    @location = Location.find(params[:id])
  end

  # Action for updating an existing Location
  # Cache is cleared and Forecast is created
  # if needed, in addition to geocoding and querying
  # weather
  def update
    @location = Location.find(params[:id])
    if @location.update(location_params)
      @location.geocode
      Forecast.find_or_create_by(zip_code: @location.zip_code)
      @location.query_forecast
      @location.clear_cached_forecast

      redirect_to @location
    else
      render :edit, status: unprocessable_entity
    end
  end

  # Action for removing a Location
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    redirect_to locations_path
  end

  private

  # Strong params
  def location_params
    params.require(:location).permit(:address)
  end
end
