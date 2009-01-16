class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :task
  has_many :time_slices, :as => :activity
  has_many :blockages
  has_many :blocked_users, :through => :blockages, :source => :user
  
  default_value_for :billable_minutes, 0
  default_value_for :total_minutes, 0
  
  validates_presence_of :task_id
  
  include Statefulness
  
  def assigned?
    !user_id.blank?
  end
  
  def billable?
    task.billable?
  end
end
