class Task < ActiveRecord::Base
  belongs_to :task_list
  has_many :assignments, :dependent => :destroy
  has_many :blockages, :through => :assignments
  has_many :time_slices, :as => :activity, :dependent => :destroy
  
  validates_presence_of :name, :task_list_id
  validates_numericality_of :assignments_count, :greater_than_or_equal_to => 0
  
  named_scope :unassigned, :conditions => { :assignments_count => 0 }
  named_scope :for_user, lambda { |user| { :include => :assignments, :conditions => [ "tasks.anybody = ? OR assignments.user_id = ? OR (assignments.user_id IS NULL AND assignments.role_id IN (?))", true, user.id, user.role_ids ] } }
  
  include Statefulness
  
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
  
  def blocked?
    assignments.any? { |a| a.blocked? }
  end
end
