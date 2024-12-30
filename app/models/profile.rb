class Profile < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar
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

  def gender_display
    GENDER_DISPLAY[gender.to_sym]
  end
end
