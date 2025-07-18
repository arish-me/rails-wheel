module Candidates
  class SearchStatusComponent < ViewComponent::Base
    attr_reader :candidate

    delegate :actively_looking?, :open?, to: :candidate

    def initialize(candidate)
      @candidate = candidate
    end

    def render?
      candidate&.search_status&.present?
    end

    def humanize(enum_value)
      # i18n-tasks-use t('developers.search_status.actively_looking')
      # i18n-tasks-use t('developers.search_status.not_interested')
      # i18n-tasks-use t('developers.search_status.open')
      Candidate.human_attribute_name "search_status.#{enum_value}"
    end
  end
end
