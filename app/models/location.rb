class Location < ApplicationRecord
  # attr_accessor :location_search
  belongs_to :locatable, polymorphic: true

  scope :top_countries, lambda { |limit = ENV.fetch('TOP_COUNTRIES', 5)|
    group(:country)
      .where.not(country: nil)
      .order(count_all: :desc)
      .limit(limit)
      .count
      .keys
  }

  scope :not_top_countries, lambda { |limit = ENV.fetch('TOP_COUNTRIES', 5)|
    where.not(country: top_countries(limit))
         .select(:country)
         .distinct
         .order(:country)
         .pluck(:country)
  }

  # validates :time_zone, presence: true
  # validates :utc_offset, presence: true
  validate :valid_coordinates

  before_validation :geocode,
                    if: lambda { |location|
                      location.will_save_change_to_city? ||
                        location.will_save_change_to_state? ||
                        location.will_save_change_to_country?
                    },
                    unless: lambda { |location|
                      location.new_record? && latitude.present? && longitude.present?
                    }

  def missing_fields?
    country.blank?
  end

  def location_search
    # Only compose the address if city, state, or country are present (i.e., it's an existing record with data)
    if city.present? || state.present? || country.present?
      [city, state, country].compact.join(', ')
    else
      @location_search # Return the value of the accessor if it was set manually
    end
  end

  def location_search=(value)
    @location_search = value
    return if value.blank?

    parts = value.split(',').map(&:strip)
    self.city = parts[0]
    self.state = parts[1]
    self.country = parts[2]
  end

  def job_location
    [city, country].compact.join(', ')
  end

  def query
    @location_search.presence || [city, state, country].compact.join(', ')
  end

  private

  def valid_coordinates
    if latitude.blank? || longitude.blank?
      # i18n-tasks-use t('activerecord.errors.models.location.invalid_coordinates')
      # errors.add(:city, :invalid_coordinates)
      errors.add(:base, 'Please Enter Correct Location')
    end
    errors.add(:base, 'Please Enter Correct Location') if time_zone.blank? || utc_offset.blank?

    return unless time_zone.blank? || time_zone.blank?

    errors.add(:base, 'Please Enter Correct Location')
  end

  def geocode
    if (result = Geocoder.search(query).first)
      self.city = result.city || result.city_district
      self.state = result.state
      self.country = result.country
      self.country_code = result.country_code
      self.latitude = result.latitude
      self.longitude = result.longitude
      self.data = result.data
      self.time_zone = TimezoneFinder.create.timezone_at(lat: latitude.to_d, lng: longitude.to_d)
      self.utc_offset = ActiveSupport::TimeZone.new(time_zone).utc_offset
    else
      self.latitude = nil # Invalidate record via #valid_coordinates.
    end
  end
end
