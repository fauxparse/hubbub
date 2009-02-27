class Blockage < ActiveRecord::Base
  belongs_to :task, :counter_cache => true
  belongs_to :user
  belongs_to :blocker, :class_name => "User"
  
  validates_presence_of :task_id, :description
end
