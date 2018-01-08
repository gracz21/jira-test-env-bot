ENV['RACK_ENV'] ||= 'development'

require 'atlassian/jwt'
require 'json'
require 'net/http'
require 'pry'
require 'sinatra'
require 'uri'

require_relative 'services/github/pull_request_parser'

post '/installed' do
  request.body.rewind
  request_payload = JSON.parse(request.body.read)
  puts request_payload['sharedSecret']
end

post '/pull_request_changed' do
  request.body.rewind
  request_payload = JSON.parse(request.body.read)
  return unless %w[opened reopened closed].include?(request_payload['action'])

  parsed_payload = Github::PullRequestParser
                   .new(github_payload: request_payload)
                   .call
  parsed_payload.to_json
end
