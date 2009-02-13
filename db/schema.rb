# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090212224505) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "subdomain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "agency_id"
  end

  add_index "accounts", ["subdomain"], :name => "index_accounts_on_subdomain", :unique => true

  create_table "assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.integer  "role_id"
    t.text     "description"
    t.string   "current_state"
    t.integer  "estimated_minutes"
    t.integer  "billable_minutes"
    t.integer  "total_minutes"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "blockages_count",   :default => 0
    t.date     "completed_on"
  end

  create_table "blockages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.integer  "blocker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.integer  "account_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "companies", ["account_id"], :name => "index_companies_on_account_id"

  create_table "project_roles", :force => true do |t|
    t.integer "project_id"
    t.integer "role_id"
    t.integer "user_id"
    t.integer "position"
  end

  create_table "projects", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.text     "description"
    t.string   "current_state"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.integer  "agency_id"
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "project_id"
    t.date     "starts_on"
    t.date     "ends_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "task_lists", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.text     "description"
    t.string   "current_state"
    t.integer  "open_tasks_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "task_list_id"
    t.string   "name"
    t.string   "current_state"
    t.boolean  "billable"
    t.boolean  "visible_to_client"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignments_count", :default => 0
    t.boolean  "anybody",           :default => false
    t.date     "due_on"
    t.date     "completed_on"
  end

  create_table "time_slices", :force => true do |t|
    t.integer "user_id"
    t.text    "summary"
    t.date    "date"
    t.boolean "billable"
    t.integer "minutes"
    t.integer "task_id"
    t.integer "project_id"
    t.integer "company_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "last_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.boolean  "admin"
    t.integer  "company_id"
    t.string   "name"
    t.string   "display_name"
    t.string   "email"
    t.string   "phone"
    t.string   "extension"
    t.string   "mobile"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
  end

  add_index "users", ["company_id"], :name => "index_users_on_company_id"

  create_table "wiki_pages", :force => true do |t|
    t.integer  "company_id"
    t.string   "title"
    t.text     "body"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
