class Profile < ApplicationRecord
  belongs_to :user

  enum :gender, [:he_she, :him_her, :they_them, :other]

  GENDER_DISPLAY = {
    he_she: "He/She",
    him_her: "Him/Her",
    they_them: "They/Them",
    other: "Other"
  }.freeze

  def gender_display
    GENDER_DISPLAY[gender.to_sym]
  end
end
