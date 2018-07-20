class App
  get '/jira_configs' do
    @jira_configs = JiraConfig.paginate(page: params[:page])
    haml :'jira_configs/index'
  end

  post '/installed' do
    request.body.rewind
    @request_payload = JSON.parse(request.body.read)
    Jira::ConfigCreator.new(installation_payload: @request_payload).call
  end

  post '/uninstalled' do
    request.body.rewind
    @request_payload = JSON.parse(request.body.read)
    JiraConfig.find_by(client_key: @request_payload['clientKey']).destroy
  end
end
