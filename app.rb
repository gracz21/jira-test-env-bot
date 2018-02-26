ENV['RACK_ENV'] ||= 'development'

require 'app_konfig'
require 'atlassian/jwt'
require 'json'
require 'net/http'
require 'pg'
require 'pry'
require 'sinatra'
require 'sinatra/activerecord'
require 'uri'

require_relative 'models/jira_config'

require_relative 'services/github/pull_request_parser'
require_relative 'services/jira/config_creator'
require_relative 'services/jira/test_environment_updater'

before do
  request.body.rewind
  @request_payload = JSON.parse(request.body.read)
end

post '/installed' do
  Jira::ConfigCreator.new(installation_payload: @request_payload).call
end

post '/uninstalled' do
end

post '/pull_request_changed' do
  halt 204 unless %w[opened reopened closed].include?(@request_payload['action'])

  parsed_payload = Github::PullRequestParser
                   .new(github_payload: @request_payload)
                   .call
  results = Jira::TestEnvironmentUpdater.new(parsed_payload).call
  status results[:code]
  body results[:body]
end
