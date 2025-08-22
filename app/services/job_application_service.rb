require "ostruct"

class JobApplicationService
  attr_reader :application, :user

  def initialize(application, user = nil)
    @application = application
    @user = user
  end

  # ============================================================================
  # APPLICATION MANAGEMENT
  # ============================================================================

  def create_application(params)
    result = OpenStruct.new(success: false, message: nil, application: nil)

    # Check if user already applied
    if application.job.has_applicant?(user.candidate)
      result.message = "You have already applied to this job."
      return result
    end

    # Check if job can be applied to
    unless application.job.can_be_applied_to?
      result.message = "This job is no longer accepting applications."
      return result
    end

    # Set application attributes
    application.assign_attributes(params)
    application.candidate = user.candidate
    application.user = user

    if application.save
      result.success = true
      result.message = "Your application was submitted successfully!"
      result.application = application
    else
      result.message = "Failed to submit application. Please check your information."
    end

    result
  end

  def update_application(params)
    result = OpenStruct.new(success: false, message: nil)

    unless can_edit_application?
      result.message = "You can't edit this application."
      return result
    end

    if application.update(params)
      result.success = true
      result.message = "Application was successfully updated."
    else
      result.message = "Failed to update application. Please check your information."
    end

    result
  end

  def withdraw_application
    result = OpenStruct.new(success: false, message: nil)

    unless can_withdraw_application?
      result.message = "You can't withdraw this application."
      return result
    end

    if application.withdraw!
      result.success = true
      result.message = "Your application has been withdrawn."
    else
      result.message = "Failed to withdraw application."
    end

    result
  end

  def re_apply
    result = OpenStruct.new(success: false, message: nil)

    unless can_re_apply?
      result.message = "You can't re-apply for this application."
      return result
    end

    if application.applied!
      result.success = true
      result.message = "Your application has been resumed."
    else
      result.message = "Failed to resume application."
    end

    result
  end

  def update_status(new_status, status_notes = nil, reviewer = nil)
    result = OpenStruct.new(success: false, message: nil)

    unless JobApplication::STATUSES.include?(new_status)
      result.message = "Invalid status."
      return result
    end

    if application.update(
      status: new_status,
      status_notes: status_notes,
      reviewed_by: reviewer
    )
      result.success = true
      result.message = "Application status updated to #{new_status.titleize}."
    else
      result.message = "Failed to update application status."
    end

    result
  end

  # ============================================================================
  # PERMISSION CHECKS
  # ============================================================================

  def can_view_application?
    user == application.user || user.company == application.job.company
  end

  def can_edit_application?
    user == application.user && application.can_be_withdrawn?
  end

  def can_withdraw_application?
    user == application.user && application.can_be_withdrawn?
  end

  def can_re_apply?
    user == application.user && application.can_be_re_apply?
  end

  def can_update_status?
    user.company == application.job.company
  end

  # ============================================================================
  # STATISTICS
  # ============================================================================

  def self.get_application_stats(job)
    applications = job.job_applications

    {
      total: applications.count,
      new: applications.applied.count,
      reviewing: applications.reviewing.count,
      shortlisted: applications.shortlisted.count,
      interviewed: applications.interviewed.count,
      offered: applications.offered.count,
      rejected: applications.rejected.count,
      withdrawn: applications.withdrawn.count,
      quick_applies: applications.quick_applies.count,
      with_cover_letter: applications.with_cover_letter.count
    }
  end

  def self.get_recent_applications(job, limit = 5)
    job.job_applications.with_applicant_details.recent.limit(limit)
  end

  # ============================================================================
  # SEARCH AND FILTERING
  # ============================================================================

  def self.search_applications(job, query)
    job.job_applications.with_applicant_details.search_by_content(query)
  end

  def self.filter_by_status(job, status)
    job.job_applications.with_applicant_details.by_status(status)
  end

  def self.filter_by_type(job, type)
    case type
    when "quick_apply"
      job.job_applications.with_applicant_details.quick_applies
    when "standard"
      job.job_applications.with_applicant_details.with_cover_letter
    else
      job.job_applications.with_applicant_details
    end
  end
end
