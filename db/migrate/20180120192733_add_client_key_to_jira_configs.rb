class AddClientKeyToJiraConfigs < ActiveRecord::Migration[5.1]
  def change
    add_column :jira_configs, :client_key, :string
    add_index :jira_configs, :client_key, unique: true
  end
end
