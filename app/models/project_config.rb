class ProjectConfig < ActiveRecord::Base
  belongs_to :jira_config

  validates_presence_of :repo_name, :staging_url, :jira_config
  validates_uniqueness_of :repo_name
end
