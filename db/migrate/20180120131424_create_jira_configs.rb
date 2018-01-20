class CreateJiraConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :jira_configs do |t|
      t.string :url
      t.string :shared_secret
      t.string :test_env_field_id
      t.timestamps null: false
    end
  end
end
