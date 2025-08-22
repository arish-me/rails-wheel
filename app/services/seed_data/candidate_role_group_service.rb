# frozen_string_literal: true

# SeedData::CandidateRoleGroupService.call
module SeedData
  class CandidateRoleGroupService < BaseService
    CANDIDATE_ROLE_GROUP = [
      { name: 'engineering' },
      { name: 'designer' },
      { name: 'operations' },
      { name: 'sales' },
      { name: 'marketing' },
      { name: 'management' },
      { name: 'other engineering' },
      { name: 'other' }
    ].freeze

    def call
      create_candidate_role_groups
    end

    private

    def create_candidate_role_groups
      log 'Creating Candidate Role Groups...'

      CANDIDATE_ROLE_GROUP.each do |perm|
        CandidateRoleGroup.find_or_create_by!(name: perm[:name])
      end

      log "Candidate Role Groups created: #{CANDIDATE_ROLE_GROUP.pluck(:name).join(', ')}"
    end
  end
end
