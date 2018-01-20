class JiraConfig < ActiveRecord::Base
  validates_presence_of :client_key, :url, :shared_secret
  validates_uniqueness_of :client_key
end
