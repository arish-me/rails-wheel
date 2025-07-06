module Candidates
  class SearchStatusComponent < ViewComponent::Base
    attr_reader :work_preference

    delegate :actively_looking?, :open?, to: :work_preference

    def initialize(work_preference)
      @work_preference = work_preference
    end

    def render?
      work_preference&.search_status&.present?
    end

    def humanize(enum_value)
      # i18n-tasks-use t('developers.search_status.actively_looking')
      # i18n-tasks-use t('developers.search_status.not_interested')
      # i18n-tasks-use t('developers.search_status.open')
      WorkPreference.human_attribute_name "search_status.#{enum_value}"
    end
  end
end
