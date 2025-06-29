class Candidate < ApplicationRecord
  belongs_to :user
  has_one :profile, class_name: "Candidate::Profile", dependent: :destroy

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :profile

  # enum :search_status, {
  #   actively_looking: 1,
  #   open: 2,
  #   not_interested: 3,
  #   invisible: 4
  # }

  def actively_looking?
  end
  def open?
  end
  def not_interested?
  end
  def invisible?
  end
end
