class Profile < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar do |attachable|
    attachable.variant :thumbnail, resize_to_fill: [ 150, 150 ]
    attachable.variant :small, resize_to_fill: [ 100, 100 ]
    attachable.variant :icon, resize_to_fill: [ 50, 50 ]
  end

  enum :gender, [ :he_she, :him_her, :they_them, :other ]
  enum :theme_preference, { system: 0, light: 1, dark: 2 }, default: :system

  GENDER_DISPLAY = {
    he_she: "He/She",
    him_her: "Him/Her",
    they_them: "They/Them",
    other: "Other"
  }.freeze

  validates :first_name, presence: true, length: { in: 3..50 }
  validates :last_name, presence: true, length: { in: 3..50 }
  validates :gender, inclusion: { in: genders.keys }, allow_nil: true
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :phone_number, format: { with: /\A\+?[\d\s\-\(\)]{7,20}\z/ }, allow_blank: true
  validates :date_of_birth, presence: false
  validates :location, length: { maximum: 100 }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :social_links, length: { maximum: 1000 }, allow_blank: true

  def display_name
    [ first_name, last_name ].compact.join(" ").presence || user&.email
  end

  def full_name
    [ first_name, middle_name, last_name ].compact.join(" ").presence || user&.email
  end

  def initials
    [ first_name&.first, last_name&.first ].compact.join("").upcase
  end

  def gender_display
    GENDER_DISPLAY[gender.to_sym] if gender.present?
  end

  def age
    return nil unless date_of_birth
    now = Time.now.utc.to_date
    now.year - date_of_birth.year - (date_of_birth.to_date.change(year: now.year) > now ? 1 : 0)
  end

  def attach_avatar(image_url)
    return if avatar.attached? # Avoid re-downloading if avatar is already attached

    begin
      uri = URI.parse(image_url)
      avatar_file = uri.open
      avatar.attach(io: avatar_file, filename: "avatar.jpg", content_type: avatar_file.content_type)
    rescue StandardError => e
      Rails.logger.error "Failed to attach avatar: #{e.message}"
    end
  end
end
