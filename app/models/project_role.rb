class ProjectRole < ActiveRecord::Base
  belongs_to :project
  belongs_to :role
  belongs_to :user
  
  acts_as_list
  
  validates_presence_of :project_id, :role_id
end
