class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :task, :counter_cache => true
  has_many :time_slices, :finder_sql => 'SELECT * FROM time_slices WHERE task_id = #{task_id} AND user_id = #{user_id}'
  has_many :blockages, :dependent => :destroy
  has_many :blocked_users, :through => :blockages, :source => :user
  
  default_value_for :billable_minutes, 0
  default_value_for :total_minutes, 0
  
  validates_presence_of :task_id, :unless => :assigning_from_nested_attributes?
  validates_presence_of :role_id, :unless => :assigned?
  
  after_create :assign_time_slices_from_task
  before_destroy :reassign_time_slices_to_task

  composed_of :estimated_time, :class_name => "Hour", :mapping => %w(estimated_minutes minutes)
  composed_of :recorded_time, :class_name => "Hour", :mapping => %w(total_minutes minutes)
  
  include Statefulness
  
  # Returns true if this assignment has a specific user.
  def assigned?
    !user_id.blank?
  end
  
  # Returns true if work on this assignment is billable.
  def billable?
    task.billable?
  end
  
  def blocked?
    blockages_count > 0
  end
  
  def estimated?
    estimated_minutes?
  end
  
  # Lets the assignment work with nested_attributes. Hopefully this won't
  # be needed anymore after Rails 2.3 final!
  def _delete=(value)
    @assigning_from_nested_attributes = true
  end
  
  def <=>(another)
    if assigned?
      another.assigned? ? to_s <=> another.to_s : -1
    else
      another.assigned? ? 1 : 0
    end
  end
  
  def to_s
    assigned? ? user.display_name : "(any #{role})"
  end
  
  def description
    super || role
  end
  
  def company
    task && task.company
  end
  
  def on_complete
    update_attribute :completed_on, Date.today
  end
  
protected
  # Make sure time recorded by a user against a task gets associated with this assignment.
  def assign_time_slices_from_task
    TimeSlice.update_all [ "task_id = ?", self.id ], [ "time_slices.user_id = ? AND time_slices.task_id = ?", user_id, task.id ]
  end

  # Make sure time recorded against a task is not lost when the assignment is destroyed.
  def reassign_time_slices_to_task
    time_slices.each do |t|
      t.update_attribute :task, task
    end
  end
  
  def assigning_from_nested_attributes?
    @assigning_from_nested_attributes
  end
end
