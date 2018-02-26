module Github
  class PullRequestParser
    BASE_DOMAIN = '.devguru.co'.freeze
    private_constant :BASE_DOMAIN

    ISSUE_NAME_REGEX = /(?:\s?|^|)([A-Z]+-[0-9]+)(?=\s|$|\])/
    private_constant :ISSUE_NAME_REGEX

    def initialize(github_payload:)
      @github_payload = github_payload
    end

    def call
      {
        pr_status: calculate_pr_status,
        issue_key: parse_issue_key,
        integration_url: generate_integration_url,
        staging_url: generate_staging_url
      }
    end

    private

    attr_reader :github_payload

    def calculate_pr_status
      action = github_payload['action']
      merged = github_payload['pull_request']['merged']

      action == 'closed' && merged ? 'merged' : action
    end

    def parse_issue_key
      github_payload['pull_request']['title'][ISSUE_NAME_REGEX]
    end

    def generate_integration_url
      project_name = github_payload['repository']['name']
      pr_number = github_payload['number']

      "http://#{project_name}-#{pr_number}.integration#{BASE_DOMAIN}"
    end

    def generate_staging_url
      project_name = github_payload['repository']['name']

      "http://#{project_name}.staging#{BASE_DOMAIN}"
    end
  end
end
