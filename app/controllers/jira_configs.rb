class App
  get '/jira_configs' do
    @jira_configs = JiraConfig.all
    haml :'jira_configs/index'
  end

  post '/installed' do
    Jira::ConfigCreator.new(installation_payload: @request_payload).call
  end

  post '/uninstalled' do
    JiraConfig.find_by(client_key: @request_payload['clientKey']).destroy
  end
end
