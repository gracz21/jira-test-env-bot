ENV['RACK_ENV'] ||= 'development'

require 'bundler'
require 'net/http'

Bundler.require(:default, ENV['RACK_ENV'].to_sym)

set :root, File.dirname(__FILE__)
require File.join(settings.root, '/config/initializers/autoloader.rb')

before do
  request.body.rewind
  @request_payload = JSON.parse(request.body.read)
end

post '/installed' do
  Jira::ConfigCreator.new(installation_payload: @request_payload).call
end

post '/uninstalled' do
  JiraConfig.find_by(client_key: @request_payload['clientKey']).destroy
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
