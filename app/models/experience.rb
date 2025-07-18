class Experience < ApplicationRecord
  belongs_to :candidate

  validates :company_name, presence: true
  validates :job_title, presence: true
  validates :start_date, presence: true
  validate :end_date_after_start_date, unless: :current_job

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "cannot be before start date")
    end
  end
end
