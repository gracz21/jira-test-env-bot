require_relative 'request/get'
require_relative 'request/put'

module Jira
  class TestEnvironmentUpdater
    REQUEST_API_BASE = 'rest/api/2/issue'.freeze
    private_constant :REQUEST_API_BASE

    def initialize(pr_status:, issue_key:, integration_url:, staging_url:)
      @pr_status = pr_status
      @url = "#{REQUEST_URL_BASE}/#{issue_key}"
      @integration_url = integration_url
      @staging_url = staging_url
    end

    def call
      field_value = current_field_value
      request_body = build_body(value: field_value)
      update_issue(body: request_body)
    end

    private

    attr_reader :pr_status, :url, :integration_url, :staging_url

    def current_field_value
      response = Jira::Request::Get.new(url: url).call
      JSON.parse(response.body)['fields'][AppConfig.test_env_field_id] || ''
    end

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

    def update_issue(body:)
      Jira::Request::Put.new(url: url, shared_secret: config.shared_secret, body: body).call
    end
  end
end
