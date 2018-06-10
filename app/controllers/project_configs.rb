class App
  get '/project_configs' do
    @project_configs = ProjectConfig.paginate(page: params[:page]).eager_load(:jira_config)
    haml :'project_configs/index'
  end
end
