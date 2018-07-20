class App
  get '/project_configs' do
    @project_configs = ProjectConfig.paginate(page: params[:page]).eager_load(:jira_config)
    @any_jira_config_exists = JiraConfig.exists?
    haml :'project_configs/index'
  end

  get '/project_configs/new' do
    @project_config = ProjectConfig.new
    @jira_configs = JiraConfig.all
    haml :'project_configs/new'
  end

  post '/project_configs/' do
    @project_config = ProjectConfig.new(params[:project_config])

    if @project_config.save
      flash[:notice] = 'New project config created'
      redirect '/project_configs'
    else
      flash[:notice] = @project_config.errors.full_messages
      @jira_configs = JiraConfig.all
      haml :'project_configs/new'
    end
  end

  get '/project_configs/edit/:id' do
    @project_config = ProjectConfig.find(params[:id])
    @jira_configs = JiraConfig.all
    haml :'project_configs/edit'
  end

  put '/project_configs/:id' do
    @project_config = ProjectConfig.find(params[:id])

    if @project_config.update(params[:project_config])
      flash[:notice] = 'Project config updated'
      redirect '/project_configs'
    else
      flash[:notice] = @project_config.errors.full_messages
      @jira_configs = JiraConfig.all
      haml :'project_configs/edit'
    end
  end

  delete '/project_configs/:id' do
    ProjectConfig.destroy(params[:id])
    flash[:notice] = 'Project config deleted'
    redirect '/project_configs'
  end
end
