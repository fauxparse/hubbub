class Blockage < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignment, :include => :task
  belongs_to :blocker, :class => "User"
end
