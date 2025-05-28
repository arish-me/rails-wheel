module ProfilesHelper
  def display_user_name(user)
    if user.profile.present?
      [ user.profile.first_name, user.profile.middle_name, user.profile.last_name ].compact.join(" ")
    else
      "Profile not set"
    end
  end

  def flag_emoji_for(country_code)
    return '' if country_code.blank?

    # Convert country code to uppercase
    country_code = country_code.upcase

    # Country code should be 2 characters
    return '' if country_code.length != 2

    # Convert country code characters to regional indicator symbols
    # Each letter is converted to an emoji regional indicator symbol (A-Z)
    # The Unicode for these symbols starts at 0x1F1E6 for "A"
    country_code.codepoints.map { |c| (c - 65 + 0x1F1E6).chr(Encoding::UTF_8) }.join
  end

  def timezone_options
    # Common timezone options with their standard names
    timezones = ActiveSupport::TimeZone.all.map do |tz|
      offset_display = tz.now.strftime("%:z")
      formatted_name = "<span class='timezone-offset'>#{offset_display}</span> <span class='timezone-name'>#{tz.name.gsub('_', ' ')}</span>".html_safe
      [formatted_name, tz.name]
    end
    
    # Sort by offset
    timezones.sort_by { |_, name| ActiveSupport::TimeZone[name].now.utc_offset }
  end

  def country_options
    # List of countries with flag emojis
    ISO3166::Country.all.map do |country|
      flag = flag_emoji_for(country.alpha2)
      name_with_flag = "<span class='country-flag'>#{flag}</span> <span>#{country.iso_short_name}</span>".html_safe
      [name_with_flag, country.alpha2]
    end.sort_by { |name, _| name.downcase }
  end

  def detect_timezone_from_ip(ip_address)
    return 'UTC' if ip_address.blank?

    begin
      # Try to get timezone from IP using geocoder
      result = Geocoder.search(ip_address).first
      if result && result.data['timezone'].present?
        return result.data['timezone']
      end
    rescue => e
      Rails.logger.error "Error detecting timezone from IP: #{e.message}"
    end

    # Default to UTC if detection fails
    'UTC'
  end

  def detect_country_from_ip(ip_address)
    return nil if ip_address.blank?

    begin
      # Try to get country from IP using geocoder
      result = Geocoder.search(ip_address).first
      if result && result.country_code.present?
        return result.country_code.upcase
      end
    rescue => e
      Rails.logger.error "Error detecting country from IP: #{e.message}"
    end

    # Return nil if detection fails
    nil
  end
end
