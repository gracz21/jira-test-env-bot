module Jira
  class TestEnvironmentUpdater
    REQUEST_URL_BASE = "#{AppConfig.jira_base}/rest/api/2/issue".freeze
    private_constant :REQUEST_URL_BASE

    def initialize(pr_status:, issue_key:, integration_url:, staging_url:)
      @pr_status = pr_status
      @url = "#{REQUEST_URL_BASE}/#{issue_key}"
      @integration_url = integration_url
      @staging_url = staging_url
    end

    def call
      url = "#{REQUEST_URL_BASE}/#{issue_key}"
      jwt = generate_jwt(url: url)
      update_issue(url: url, jwt: jwt)
    end

    private

    attr_reader :pr_status, :url, :integration_url, :staging_url

    end

    end
  end
end
