class Profile < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar do |attachable|
    attachable.variant :thumbnail, resize_to_fill: [ 300, 300 ]
  end
  enum :gender, [:he_she, :him_her, :they_them, :other]

  GENDER_DISPLAY = {
    he_she: "He/She",
    him_her: "Him/Her",
    they_them: "They/Them",
    other: "Other"
  }.freeze

  validates :first_name, presence: true, length: { in: 3..50 }
  validates :last_name, presence: true, length: { in: 3..50 }
  validates :gender, presence: true, inclusion: { in: genders.keys }


  def display_name
    [ first_name, last_name ].compact.join(" ").presence || email
  end

  def initial
    (display_name&.first || email.first).upcase
  end

  def gender_display
    GENDER_DISPLAY[gender.to_sym]
  end
end
