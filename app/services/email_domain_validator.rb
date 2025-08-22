class EmailDomainValidator
  # Common personal email domains that should be rejected for company users
  PERSONAL_DOMAINS = [
    "gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "live.com",
    "aol.com", "icloud.com", "me.com", "mac.com", "protonmail.com",
    "tutanota.com", "yandex.com", "mail.ru", "gmx.com", "zoho.com",
    "fastmail.com", "hushmail.com", "guerrillamail.com", "10minutemail.com",
    "yopmail.com", "tempmail.com", "mailinator.com", "throwaway.com",
    "dispostable.com", "mailnesia.com", "sharklasers.com", "guerrillamailblock.com",
    "pokemail.net", "spam4.me", "bccto.me", "chacuo.net", "dispostable.com",
    "fakeinbox.com", "fakeinbox.net", "fakemailgenerator.com", "getairmail.com",
    "maildrop.cc", "mailnesia.com", "mintemail.com", "mytrashmail.com",
    "nwytg.net", "sharklasers.com", "spamspot.com", "spam.la", "tempr.email",
    "tmpeml.com", "tmpmail.org", "trashmail.com", "trashmail.net", "trashmailer.com",
    "wegwerfemail.de", "wegwerfemail.net", "wegwerfemail.org", "wegwerfemail.info",
    "wegwerfemail.com", "wegwerfemail.de", "wegwerfemail.net", "wegwerfemail.org",
    "wegwerfemail.info", "wegwerfemail.com", "wegwerfemail.de", "wegwerfemail.net",
    "wegwerfemail.org", "wegwerfemail.info", "wegwerfemail.com", "wegwerfemail.de",
    "wegwerfemail.net", "wegwerfemail.org", "wegwerfemail.info", "wegwerfemail.com"
  ].freeze

  def self.personal_domain?(email)
    return false if email.blank?

    domain = extract_domain(email)
    PERSONAL_DOMAINS.include?(domain.downcase)
  end

  def self.business_domain?(email)
    return false if email.blank?

    domain = extract_domain(email)
    PERSONAL_DOMAINS.exclude?(domain.downcase)
  end

  def self.extract_domain(email)
    return nil if email.blank?
    return nil unless email.include?("@")

    email.split("@").last&.downcase
  end

  def self.validate_company_email(email)
    return { valid: false, message: "Email is required" } if email.blank?
    return { valid: false, message: "Invalid email format" } unless email.match?(/\A[^@\s]+@[^@\s]+\z/)

    if personal_domain?(email)
      {
        valid: false,
        message: "Please use a business email address. Personal email domains like Gmail, Yahoo, etc. are not allowed for company accounts."
      }
    else
      { valid: true, message: "Email domain is valid" }
    end
  end
end
