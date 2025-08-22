class Experience < ApplicationRecord
  belongs_to :candidate

  validates :company_name, presence: true, length: { maximum: 100 }
  validates :job_title, presence: true, length: { maximum: 100 }
  validates :start_date, presence: true
  validates :description, presence: true, length: { maximum: 500 }
  validates :end_date, presence: true, unless: :current_job
  validate :end_date_after_start_date, unless: :current_job
  validate :end_date_blank_if_current_job

  # Suggestion: You could add uniqueness validation for company_name per candidate if needed
  # validates :company_name, uniqueness: { scope: :candidate_id }

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    return unless end_date < start_date

    errors.add(:end_date, 'cannot be before start date')
  end

  def end_date_blank_if_current_job
    return unless current_job && end_date.present?

    errors.add(:end_date, 'must be blank if this is your current job')
  end
end
