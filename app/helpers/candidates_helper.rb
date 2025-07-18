module CandidatesHelper
  def experience_date_range(experience)
    return "" unless experience.start_date.present?
    start_year = experience.start_date.year
    if experience.current_job
      "#{start_year} to <span class=\"font-semibold\">Present</span>".html_safe
    elsif experience.end_date.present?
      end_year = experience.end_date.year
      "#{start_year} to #{end_year}"
    else
      start_year.to_s
    end
  end
end
