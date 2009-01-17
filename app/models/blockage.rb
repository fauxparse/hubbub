class Blockage < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignment, :include => :task, :counter_cache => true
  belongs_to :blocker, :class_name => "User"
end
