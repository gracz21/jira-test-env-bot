ENV['RACK_ENV'] ||= 'development'

require 'bundler'
require 'net/http'

Bundler.require(:default, ENV['RACK_ENV'].to_sym)

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  register WillPaginate::Sinatra

  set :method_override, true
  set :root, File.dirname(__FILE__)
  set :haml, format: :html5, layout: :application
  set :sprockets, Sprockets::Environment.new
  set :views, File.join(root, '/app/views')

  # Include and compress assets
  sprockets.append_path 'app/assets/stylesheets'
  sprockets.append_path 'app/assets/javascripts'
  sprockets.js_compressor  = :uglify
  sprockets.css_compressor = :scss

  # Append bootstrap and popper_js gems JS assets to sprockets
  sprockets.append_path File.join(
    Gem::Specification.find_by_name('popper_js').gem_dir, 'assets', 'javascripts'
  )
  sprockets.append_path File.join(
    Gem::Specification.find_by_name('bootstrap').gem_dir, 'assets', 'javascripts'
  )

  # Serve assets
  get '/app/assets/*' do
    env['PATH_INFO'].sub!('/app/assets', '')
    settings.sprockets.call(env)
  end

  require File.join(root, '/config/initializers/autoloader.rb')

  get '/' do
    redirect '/project_configs'
  end

  get '/descriptor' do
    content_type 'application/json'
    erb :'atlassian_connect.json'
  end

  post '/pull_request_changed' do
    request.body.rewind
    @request_payload = JSON.parse(request.body.read)
    halt 204 unless %w[opened reopened closed].include?(@request_payload['action'])

    parsed_payload = Github::PullRequestParser
                     .new(github_payload: @request_payload)
                     .call
    results = Jira::TestEnvironmentUpdater.new(parsed_payload).call
    status results[:code]
    body results[:body]
  end
end
