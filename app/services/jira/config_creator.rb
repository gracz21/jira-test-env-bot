module Jira
  class ConfigCreator
    def initialize(installation_payload:)
      @installation_payload = installation_payload
    end

    def call
      JiraConfig.create!(parse_installation_payload)
    end

    private

    attr_reader :installation_payload

    def parse_installation_payload
      {
        client_key: installation_payload['clientKey'],
        url: installation_payload['baseUrl'],
        shared_secret: installation_payload['sharedSecret']
      }
    end
  end
end
