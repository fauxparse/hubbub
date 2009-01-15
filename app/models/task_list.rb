class TaskList < ActiveRecord::Base
  belongs_to :project
  
  validates_presence_of :name, :project_id
  include Statefulness
  
  alias_attribute :to_s, :name

  def to_param
    "#{id}_#{name.parameterize}"
  end
  
  def empty?
    open_tasks_count.zero?
  end
end
