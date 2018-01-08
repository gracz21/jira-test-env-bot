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
      pr_status = determinate_pr_status

      {
        pr_status: pr_status,
        issue_key: parse_issue_key,
        testing_url_env: generate_testing_env_url(pr_status: pr_status)
      }
    end

    private

    attr_reader :github_payload

    def determinate_pr_status
      action = github_payload['action']
      merged = github_payload['pull_request']['merged']

      action == 'closed' && merged ? 'merged' : action
    end

    def parse_issue_key
      github_payload['pull_request']['title'][ISSUE_NAME_REGEX]
    end

    def generate_testing_env_url(pr_status:)
      project_name = github_payload['repository']['name']
      pr_number = github_payload['number']
      env = pr_status == 'merged' ? '.staging' : "-#{pr_number}.integration"

      "http://#{project_name}#{env}#{BASE_DOMAIN}"
    end
  end
end
