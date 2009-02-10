class Task < ActiveRecord::Base
  belongs_to :task_list
  delegate :project, :to => :task_list
  has_many :assignments, :dependent => :destroy, :include => [ :user, :role ]
  has_many :blockages, :through => :assignments
  has_many :time_slices, :as => :activity, :dependent => :destroy
  
  accepts_nested_attributes_for :assignments, :allow_destroy => true
  default_value_for :billable, true
  
  validates_presence_of :name, :task_list_id
  validates_numericality_of :assignments_count, :greater_than_or_equal_to => 0
  
  named_scope :unassigned, :conditions => { :anybody => false, :assignments_count => 0 }
  named_scope :for_user, lambda { |user| { :include => :assignments, :conditions => user.nil? ? "1" : [ "tasks.anybody = ? OR assignments.user_id = ? OR (assignments.user_id IS NULL AND assignments.role_id IN (?))", true, user.id, user.role_ids ] } }
  
  include Statefulness
  
  alias_attribute :to_s, :name
  
  def can_complete?
    assignments.inject(true) { |t, a| t && (a.completed? || !a.blocked?) }
  end
  
  def on_complete
    assignments.each &:complete
  end
  
  def on_reopen
    assignments.each &:reopen
  end
  
  def assigned?
    anybody? || assignments_count > 0
  end
  
  def unassigned?
    !assigned?
  end
  
  def blocked?
    assignments.any? { |a| a.blocked? }
  end
  
  def has_due_date?
    !due_on.nil?
  end
  alias :has_due_date :has_due_date?
    
  def has_due_date=(value)
    self.due_on = nil if !value || value.to_i.zero?
  end
  
  def task
    self
  end
  
  def users
    anybody? ? project.agency.users : assignments.collect(&:user)
  end
end
