class App
  post '/installed' do
    Jira::ConfigCreator.new(installation_payload: @request_payload).call
  end

  post '/uninstalled' do
    JiraConfig.find_by(client_key: @request_payload['clientKey']).destroy
  end
end
