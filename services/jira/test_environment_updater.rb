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

    def build_body(value:)
      case pr_status
      when 'opened', 'reopened'
        value = value.concat("\n#{integration_url}") unless value.include?(integration_url)
      when 'closed'
        value.sub!(integration_url, '')
      when 'merged'
        value.sub!(integration_url, '')
        value = value.concat("\n#{staging_url}") unless value.include?(staging_url)
      end

      { fields: { AppConfig.test_env_field_id => value } }
    end
  end
end
