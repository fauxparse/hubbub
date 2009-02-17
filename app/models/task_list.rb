class TaskList < ActiveRecord::Base
  belongs_to :project
  has_many :tasks

  acts_as_list :scope => :project_id
  default_scope :order => "position ASC"
  
  validates_presence_of :name, :project_id
  validates_uniqueness_of :name, :scope => :project_id
  include Statefulness
  
  alias_attribute :to_s, :name

  def to_param
    "#{id}_#{name.parameterize}"
  end
  
  def empty?
    open_tasks_count.zero?
  end
  
  def task_positions=(order)
    order.map!(&:to_i)
    unordered_tasks = Task.find Array(order)
    max_p = tasks.maximum(:position) || 0
    unordered_tasks.map! { |t| t.update_attributes :position => (max_p += 1), :task_list_id => self.id unless t.task_list_id == self.id; t } unless new_record?
    order.zip(unordered_tasks.collect(&:position).sort).each do |id, p|
      Task.update_all("position = #{p}", "id = #{id}")
    end
  end
  
  class << self
    def order=(order)
      order.map!(&:to_i)
      lists = find Array(order)
      order.zip(lists.collect(&:position).sort).each do |id, p|
        update_all("position = #{p}", "id = #{id}")
      end
    end
  end
end
