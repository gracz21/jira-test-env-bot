module Jira
  class TestEnvironmentUpdater
    REQUEST_URL_BASE = "#{AppConfig.jira_base}/rest/api/2/issue".freeze
    private_constant :REQUEST_URL_BASE

    def initialize(issue_key:, field_value:)
      @issue_key = issue_key
      @field_value = field_value
    end

    def call
      url = "#{REQUEST_URL_BASE}/#{issue_key}"
      jwt = generate_jwt(url: url)
      update_issue(url: url, jwt: jwt)
    end

    private

    attr_reader :issue_key, :field_value

    def generate_jwt(url:)
      claim = Atlassian::Jwt.build_claims(AppConfig.issuer, url, 'put')
      JWT.encode(claim, AppConfig.shared_secret)
    end

    def update_issue(url:, jwt:)
      uri = URI("#{url}?jwt=#{jwt}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Put.new(uri.request_uri)
      request.body = { fields: { AppConfig.test_env_field_id => field_value } }.to_json
      request.content_type = 'application/json'
      http.request(request)
    end
  end
end
