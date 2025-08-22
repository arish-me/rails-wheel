require "ostruct"

class LocationsController < ApplicationController
  def city_suggestions
    query = params[:q].to_s.downcase
    cities = YAML.load_file(Rails.root.join("db/data/world_cities.json"))
    matches = cities.select do |city|
      city["name"].downcase.include?(query) ||
        city["subcountry"].to_s.downcase.include?(query) ||
        city["country"].to_s.downcase.include?(query)
    end.first(10)
    @cities = matches.map { |city| ComboboxCity.new(city) }

    respond_to do |format|
      format.turbo_stream
    end
  end
end
