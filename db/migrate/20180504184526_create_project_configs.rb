class CreateProjectConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :project_configs do |t|
      t.string :repo_name
      t.string :dynamic_staging_subdomain
      t.string :staging_url
      t.belongs_to :jira_config, foreign_key: true
      t.timestamps null: false
    end

    add_index :project_configs, :repo_name, unique: true
  end
end
