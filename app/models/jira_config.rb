class JiraConfig < ActiveRecord::Base
  has_many :project_configs, dependent: :destroy

  validates_presence_of :client_key, :url, :shared_secret
  validates_uniqueness_of :client_key
end
