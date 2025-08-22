# SeedData::CandidateRoleService.call
module SeedData
  class CandidateRoleService < BaseService
    # Defines the default data for candidate role groups and their associated roles.
    # Each hash in the array represents a group with a 'group_name' and an array of 'roles'.
    DEFAULT_DATA = [
      {
        group_name: 'Engineering',
        roles: [
          'Software Engineer',
          'Mobile Developer',
          'Android Developer',
          'iOS Developer',
          'Front-End Developer',
          'Back-End Developer',
          'Full-Stack Developer',
          'DevOps Engineer',
          'QA Engineer',
          'Data Scientist',
          'Machine Learning Engineer',
          'Embedded Systems Engineer',
          'Cloud Engineer',
          'Site Reliability Engineer (SRE)',
          'Technical Lead',
          'Solutions Architect',
          'Game Developer',
          'Blockchain Developer'
        ]
      },
      {
        group_name: 'Designer',
        roles: [
          'UI/UX Designer',
          'Product Designer',
          'Graphic Designer',
          'Web Designer',
          'Interaction Designer',
          'Motion Designer',
          'Illustrator'
        ]
      },
      {
        group_name: 'Operations',
        roles: [
          'Operations Manager',
          'Project Manager',
          'Product Manager',
          'Business Analyst',
          'Supply Chain Manager',
          'Office Manager',
          'Executive Assistant'
        ]
      },
      {
        group_name: 'Sales',
        roles: [
          'Sales Representative',
          'Account Manager',
          'Business Development Representative (BDR)',
          'Sales Development Representative (SDR)',
          'Sales Engineer',
          'Key Account Manager'
        ]
      },
      {
        group_name: 'Marketing',
        roles: [
          'Marketing Manager',
          'Content Strategist',
          'SEO Specialist',
          'SEM Specialist',
          'Social Media Manager',
          'Email Marketing Specialist',
          'Growth Hacker',
          'Brand Manager',
          'Digital Marketing Specialist',
          'PR Specialist'
        ]
      },
      {
        group_name: 'Management',
        roles: [
          'CEO/Founder',
          'CTO',
          'COO',
          'CFO',
          'Head of Engineering',
          'VP of Product',
          'Team Lead',
          'Department Manager'
        ]
      },
      {
        group_name: 'Other Engineering', # Consider merging these into "Engineering" if it makes sense.
        roles: [
          'Hardware Engineer',
          'Firmware Engineer',
          'CAD Engineer',
          'Research Engineer'
        ]
      },
      {
        group_name: 'Other',
        roles: [
          'Customer Support Specialist',
          'HR Specialist',
          'Legal Counsel',
          'Finance Analyst',
          'Admin Assistant',
          'Consultant (General)',
          'Data Entry Specialist'
        ]
      }
    ].freeze

    # Main method to call the service and create/update records.
    def call
      create_candidate_role_groups_and_roles
    end

    private

    # Iterates through the DEFAULT_DATA to create or find CandidateRoleGroup records
    # and then create or find their associated CandidateRole records.
    def create_candidate_role_groups_and_roles
      log 'Creating Candidate Role Groups and Roles...'

      DEFAULT_DATA.each do |group_data|
        group_name = group_data[:group_name]
        roles = group_data[:roles]

        # Find or create the CandidateRoleGroup
        candidate_role_group = CandidateRoleGroup.find_or_create_by!(name: group_name)
        log "  - Found/Created Candidate Role Group: '#{group_name}'"

        # Create or find associated CandidateRoles for this group
        roles.each do |role_name|
          CandidateRole.find_or_create_by!(name: role_name, candidate_role_group: candidate_role_group)
          log "    - Found/Created Candidate Role: '#{role_name}' for group '#{group_name}'"
        end
      end

      log 'All Candidate Role Groups and Roles processed successfully.'
    rescue StandardError => e
      log_error "Failed to create Candidate Role Groups and Roles: #{e.message}"
      # Depending on your BaseService and error handling, you might re-raise or handle differently.
    end
  end
end
