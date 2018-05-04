# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180504184526) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "jira_configs", force: :cascade do |t|
    t.string "url"
    t.string "shared_secret"
    t.string "test_env_field_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_key"
    t.index ["client_key"], name: "index_jira_configs_on_client_key", unique: true
  end

  create_table "project_configs", force: :cascade do |t|
    t.string "repo_name"
    t.string "dynamic_staging_subdomain"
    t.string "staging_url"
    t.bigint "jira_config_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jira_config_id"], name: "index_project_configs_on_jira_config_id"
    t.index ["repo_name"], name: "index_project_configs_on_repo_name", unique: true
  end

  add_foreign_key "project_configs", "jira_configs"
end
