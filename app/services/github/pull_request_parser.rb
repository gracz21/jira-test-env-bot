require 'dry-monads'

module Github
  class PullRequestParser
    include Dry::Monads::Result::Mixin

    DYNAMIC_STAGING_BASE_DOMAIN = '.devguru.co'.freeze
    private_constant :DYNAMIC_STAGING_BASE_DOMAIN

    ISSUE_NAME_REGEX = /(?:\s?|^|)([A-Z]+-[0-9]+)(?=\s|$|\])/
    private_constant :ISSUE_NAME_REGEX

    PAYLOAD_ERROR_MESSAGE = 'Invalid payload'.freeze
    private_constant :PAYLOAD_ERROR_MESSAGE

    def initialize(payload:)
      @payload = payload
    end

    def call
      Success(payload: payload)
        .bind(method(:identify_project))
        .bind(method(:generate_staging_url))
        .bind(method(:generate_dynamic_staging_url))
        .bind(method(:calculate_pr_status))
        .bind(method(:parse_issue_key))
    end

    private

    attr_reader :payload

    def identify_project(payload:)
      repo_name = payload['repository']['name']
      project_config = ProjectConfig.find_by(repo_name: repo_name)

      if project_config.nil?
        Failure('Project not fonud. Please, check the project configuration')
      else
        Success(payload: payload, project_config: project_config, response: {})
      end
    end

    def generate_staging_url(payload:, project_config:, response:)
      response[:staging_url] = project_config.staging_url
      Success(payload: payload, project_config: project_config, response: response)
    end

    def generate_dynamic_staging_url(payload:, project_config:, response:)
      pr_number = payload['number']
      return Failure(PAYLOAD_ERROR_MESSAGE) if pr_number.nil?

      subdomain = project_config.dynamic_staging_subdomain
      if subdomain.present?
        response[:integration_url] = "http://#{subdomain}-#{pr_number}"\
                                     ".integration#{DYNAMIC_STAGING_BASE_DOMAIN}"
      else
        response[:integration_url] = response[:staging_url]
      end
      Success(payload: payload, response: response)
    end

    def calculate_pr_status(payload:, response:)
      action = payload['action']
      merged = payload['pull_request']['merged']
      return Failure(PAYLOAD_ERROR_MESSAGE) if action.nil? || merged.nil?

      response[:pr_status] = action == 'closed' && merged ? 'merged' : action
      Success(payload: payload, response: response)
    end

    def parse_issue_key(payload:, response:)
      pr_title = payload['pull_request']['title']
      return Failure(PAYLOAD_ERROR_MESSAGE) if pr_title.nil?

      response[:issue_key] = pr_title[ISSUE_NAME_REGEX]
      Success(response)
    end
  end
end
