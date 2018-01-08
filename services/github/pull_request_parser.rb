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
        pr_action: github_payload['action'],
        issue_key: parse_issue_key,
        testing_url_env: generate_testing_env_url
      }
    end

    private

    attr_reader :github_payload

    def parse_issue_key
      github_payload['pull_request']['title'][ISSUE_NAME_REGEX]
    end

    def generate_testing_env_url
      project_name = github_payload['repository']['name']
      pr_number = github_payload['number']
      env = github_payload['action'] == 'closed' ? '.staging' : "-#{pr_number}.integration"
      "http://#{project_name}#{env}#{BASE_DOMAIN}"
    end
  end
end
