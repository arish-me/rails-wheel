module ProfilesHelper

  COUNTRY_MAPPING = {
    AF: "🇦🇫 Afghanistan",
    AL: "🇦🇱 Albania",
    DZ: "🇩🇿 Algeria",
    AD: "🇦🇩 Andorra",
    AO: "🇦🇴 Angola",
    AG: "🇦🇬 Antigua and Barbuda",
    AR: "🇦🇷 Argentina",
    AM: "🇦🇲 Armenia",
    AU: "🇦🇺 Australia",
    AT: "🇦🇹 Austria",
    AZ: "🇦🇿 Azerbaijan",
    BS: "🇧🇸 Bahamas",
    BH: "🇧🇭 Bahrain",
    BD: "🇧🇩 Bangladesh",
    BB: "🇧🇧 Barbados",
    BY: "🇧🇾 Belarus",
    BE: "🇧🇪 Belgium",
    BZ: "🇧🇿 Belize",
    BJ: "🇧🇯 Benin",
    BT: "🇧🇹 Bhutan",
    BO: "🇧🇴 Bolivia",
    BA: "🇧🇦 Bosnia and Herzegovina",
    BW: "🇧🇼 Botswana",
    BR: "🇧🇷 Brazil",
    BN: "🇧🇳 Brunei",
    BG: "🇧🇬 Bulgaria",
    BF: "🇧🇫 Burkina Faso",
    BI: "🇧🇮 Burundi",
    KH: "🇰🇭 Cambodia",
    CM: "🇨🇲 Cameroon",
    CA: "🇨🇦 Canada",
    CV: "🇨🇻 Cape Verde",
    CF: "🇨🇫 Central African Republic",
    TD: "🇹🇩 Chad",
    CL: "🇨🇱 Chile",
    CN: "🇨🇳 China",
    CO: "🇨🇴 Colombia",
    KM: "🇰🇲 Comoros",
    CG: "🇨🇬 Congo",
    CD: "🇨🇩 Congo, Democratic Republic of the",
    CR: "🇨🇷 Costa Rica",
    CI: "🇨🇮 Côte d'Ivoire",
    HR: "🇭🇷 Croatia",
    CU: "🇨🇺 Cuba",
    CY: "🇨🇾 Cyprus",
    CZ: "🇨🇿 Czech Republic",
    DK: "🇩🇰 Denmark",
    DJ: "🇩🇯 Djibouti",
    DM: "🇩🇲 Dominica",
    DO: "🇩🇴 Dominican Republic",
    EC: "🇪🇨 Ecuador",
    EG: "🇪🇬 Egypt",
    SV: "🇸🇻 El Salvador",
    GQ: "🇬🇶 Equatorial Guinea",
    ER: "🇪🇷 Eritrea",
    EE: "🇪🇪 Estonia",
    ET: "🇪🇹 Ethiopia",
    FJ: "🇫🇯 Fiji",
    FI: "🇫🇮 Finland",
    FR: "🇫🇷 France",
    GA: "🇬🇦 Gabon",
    GM: "🇬🇲 Gambia",
    GE: "🇬🇪 Georgia",
    DE: "🇩🇪 Germany",
    GH: "🇬🇭 Ghana",
    GR: "🇬🇷 Greece",
    GD: "🇬🇩 Grenada",
    GT: "🇬🇹 Guatemala",
    GN: "🇬🇳 Guinea",
    GW: "🇬🇼 Guinea-Bissau",
    GY: "🇬🇾 Guyana",
    HT: "🇭🇹 Haiti",
    HN: "🇭🇳 Honduras",
    HU: "🇭🇺 Hungary",
    IS: "🇮🇸 Iceland",
    IN: "🇮🇳 India",
    ID: "🇮🇩 Indonesia",
    IR: "🇮🇷 Iran",
    IQ: "🇮🇶 Iraq",
    IE: "🇮🇪 Ireland",
    IL: "🇮🇱 Israel",
    IT: "🇮🇹 Italy",
    JM: "🇯🇲 Jamaica",
    JP: "🇯🇵 Japan",
    JO: "🇯🇴 Jordan",
    KZ: "🇰🇿 Kazakhstan",
    KE: "🇰🇪 Kenya",
    KI: "🇰🇮 Kiribati",
    KP: "🇰🇵 North Korea",
    KR: "🇰🇷 South Korea",
    KW: "🇰🇼 Kuwait",
    KG: "🇰🇬 Kyrgyzstan",
    LA: "🇱🇦 Laos",
    LV: "🇱🇻 Latvia",
    LB: "🇱🇧 Lebanon",
    LS: "🇱🇸 Lesotho",
    LR: "🇱🇷 Liberia",
    LY: "🇱🇾 Libya",
    LI: "🇱🇮 Liechtenstein",
    LT: "🇱🇹 Lithuania",
    LU: "🇱🇺 Luxembourg",
    MK: "🇲🇰 North Macedonia",
    MG: "🇲🇬 Madagascar",
    MW: "🇲🇼 Malawi",
    MY: "🇲🇾 Malaysia",
    MV: "🇲🇻 Maldives",
    ML: "🇲🇱 Mali",
    MT: "🇲🇹 Malta",
    MH: "🇲🇭 Marshall Islands",
    MR: "🇲🇷 Mauritania",
    MU: "🇲🇺 Mauritius",
    MX: "🇲🇽 Mexico",
    FM: "🇫🇲 Micronesia",
    MD: "🇲🇩 Moldova",
    MC: "🇲🇨 Monaco",
    MN: "🇲🇳 Mongolia",
    ME: "🇲🇪 Montenegro",
    MA: "🇲🇦 Morocco",
    MZ: "🇲🇿 Mozambique",
    MM: "🇲🇲 Myanmar",
    NA: "🇳🇦 Namibia",
    NR: "🇳🇷 Nauru",
    NP: "🇳🇵 Nepal",
    NL: "🇳🇱 Netherlands",
    NZ: "🇳🇿 New Zealand",
    NI: "🇳🇮 Nicaragua",
    NE: "🇳🇪 Niger",
    NG: "🇳🇬 Nigeria",
    NO: "🇳🇴 Norway",
    OM: "🇴🇲 Oman",
    PK: "🇵🇰 Pakistan",
    PW: "🇵🇼 Palau",
    PA: "🇵🇦 Panama",
    PG: "🇵🇬 Papua New Guinea",
    PY: "🇵🇾 Paraguay",
    PE: "🇵🇪 Peru",
    PH: "🇵🇭 Philippines",
    PL: "🇵🇱 Poland",
    PT: "🇵🇹 Portugal",
    QA: "🇶🇦 Qatar",
    RO: "🇷🇴 Romania",
    RU: "🇷🇺 Russia",
    RW: "🇷🇼 Rwanda",
    KN: "🇰🇳 Saint Kitts and Nevis",
    LC: "🇱🇨 Saint Lucia",
    VC: "🇻🇨 Saint Vincent and the Grenadines",
    WS: "🇼🇸 Samoa",
    SM: "🇸🇲 San Marino",
    ST: "🇸🇹 Sao Tome and Principe",
    SA: "🇸🇦 Saudi Arabia",
    SN: "🇸🇳 Senegal",
    RS: "🇷🇸 Serbia",
    SC: "🇸🇨 Seychelles",
    SL: "🇸🇱 Sierra Leone",
    SG: "🇸🇬 Singapore",
    SK: "🇸🇰 Slovakia",
    SI: "🇸🇮 Slovenia",
    SB: "🇸🇧 Solomon Islands",
    SO: "🇸🇴 Somalia",
    ZA: "🇿🇦 South Africa",
    SS: "🇸🇸 South Sudan",
    ES: "🇪🇸 Spain",
    LK: "🇱🇰 Sri Lanka",
    SD: "🇸🇩 Sudan",
    SR: "🇸🇷 Suriname",
    SE: "🇸🇪 Sweden",
    CH: "🇨🇭 Switzerland",
    SY: "🇸🇾 Syria",
    TW: "🇹🇼 Taiwan",
    TJ: "🇹🇯 Tajikistan",
    TZ: "🇹🇿 Tanzania",
    TH: "🇹🇭 Thailand",
    TL: "🇹🇱 Timor-Leste",
    TG: "🇹🇬 Togo",
    TO: "🇹🇴 Tonga",
    TT: "🇹🇹 Trinidad and Tobago",
    TN: "🇹🇳 Tunisia",
    TR: "🇹🇷 Turkey",
    TM: "🇹🇲 Turkmenistan",
    TV: "🇹🇻 Tuvalu",
    UG: "🇺🇬 Uganda",
    UA: "🇺🇦 Ukraine",
    AE: "🇦🇪 United Arab Emirates",
    GB: "🇬🇧 United Kingdom",
    US: "🇺🇸 United States",
    UY: "🇺🇾 Uruguay",
    UZ: "🇺🇿 Uzbekistan",
    VU: "🇻🇺 Vanuatu",
    VA: "🇻🇦 Vatican City",
    VE: "🇻🇪 Venezuela",
    VN: "🇻🇳 Vietnam",
    YE: "🇾🇪 Yemen",
    ZM: "🇿🇲 Zambia",
    ZW: "🇿🇼 Zimbabwe"
  }.freeze

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
    ActiveSupport::TimeZone.all
      .sort_by { |tz| [ tz.utc_offset, tz.name ] }
      .map do |tz|
        name = tz.name.split(" - ").first.gsub(" (US & Canada)", "")
        [ "(#{tz.formatted_offset}) #{name}", tz.tzinfo.identifier ]
      end
  end

  def country_options
    COUNTRY_MAPPING.keys.map { |key| [ COUNTRY_MAPPING[key], key ] }
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
