class JiraConfig < ActiveRecord::Base
  validates :url, :shared_secret, :test_env_field_id, presence: true
end
