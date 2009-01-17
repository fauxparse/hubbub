class Task < ActiveRecord::Base
  belongs_to :task_list
  has_many :assignments
  has_many :blockages, :through => :assignments
  has_many :time_slices, :as => :activity
  
  include Statefulness
  
  def can_complete?
    assignments.inject(true) { |t, a| t && a.completed? }
  end
end
