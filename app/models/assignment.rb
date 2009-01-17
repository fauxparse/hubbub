class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :task
  has_many :time_slices, :as => :activity
  has_many :blockages, :dependent => :destroy
  has_many :blocked_users, :through => :blockages, :source => :user
  
  default_value_for :billable_minutes, 0
  default_value_for :total_minutes, 0
  
  validates_presence_of :task_id
  
  after_create :assign_time_slices_from_task
  before_destroy :reassign_time_slices_to_task
  
  include Statefulness
  
  # Returns true if this assignment has a specific user.
  def assigned?
    !user_id.blank?
  end
  
  # Returns true if work on this assignment is billable.
  def billable?
    task.billable?
  end
  
  def anyone?
    !assigned? && role_id.blank?
  end
  
protected
  # Make sure time recorded by a user against a task gets associated with this assignment.
  def assign_time_slices_from_task
    TimeSlice.update_all [ "activity_type = ?, activity_id = ?", self.class.name, self.id ], [ "time_slices.user_id = ? AND time_slices.activity_type = ? AND time_slices.activity_id = ?", user_id, task.class.name, task.id ]
  end

  # Make sure time recorded against a task is not lost when the assignment is destroyed.
  def reassign_time_slices_to_task
    time_slices.each do |t|
      t.update_attribute :activity, task
    end
  end
end
