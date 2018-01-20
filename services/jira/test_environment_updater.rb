require_relative 'request/get'
require_relative 'request/put'

module Jira
  class TestEnvironmentUpdater
    REQUEST_API_BASE = 'rest/api/2/issue'.freeze
    private_constant :REQUEST_API_BASE

    def initialize(pr_status:, issue_key:, integration_url:, staging_url:)
      @config = JiraConfig.first
      @pr_status = pr_status
      @url = "#{@config.url}/#{REQUEST_API_BASE}/#{issue_key}"
      @integration_url = integration_url
      @staging_url = staging_url
    end

    def call
      field_id = retvie_field_id
      field_value = current_field_value(field_id: field_id)
      request_body = build_body(field_id: field_id, value: field_value)
      update_issue(body: request_body)
    end

    private

    attr_reader :pr_status, :url, :integration_url, :staging_url, :config

    def retvie_field_id
      url = "#{config.url}/rest/api/2/field"
      response = Jira::Request::Get.new(url: url, shared_secret: config.shared_secret).call

      field = JSON.parse(response.body).find { |field| field['name'] == 'Testing Environment' }
      field['id']
    end

    def current_field_value(field_id:)
      response = Jira::Request::Get.new(url: url, shared_secret: config.shared_secret).call
      JSON.parse(response.body)['fields'][field_id] || ''
    end

    def build_body(field_id:, value:)
      case pr_status
      when 'opened', 'reopened'
        value = value.concat("\n#{integration_url}") unless value.include?(integration_url)
      when 'closed'
        value.sub!(integration_url, '')
      when 'merged'
        value.sub!(integration_url, '')
        value = value.concat("\n#{staging_url}") unless value.include?(staging_url)
      end

      { fields: { field_id => value } }
    end

    def update_issue(body:)
      Jira::Request::Put.new(url: url, shared_secret: config.shared_secret, body: body).call
    end
  end
end
