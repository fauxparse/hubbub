class TimeSlice < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  belongs_to :project
  belongs_to :company

  composed_of :elapsed_time, :mapping => %w(minutes minutes)
  default_value_for(:date) { |record| Date.today }
  validates_presence_of :user_id, :minutes, :date, :company_id
  validates_presence_of :project_id, :if => :task_id?

  before_validation :fill_in_project_and_company
  before_validation :check_if_billable
  after_save :update_activity_time
  before_destroy :remove_activity_time
  
  named_scope :for_user, lambda { |user| user.nil? ? {} : { :conditions => { :user_id => user.id } } }
  named_scope :for_task, lambda { |task| task.nil? ? {} : { :conditions => { :task_id => task.id } } }
  named_scope :for_project, lambda { |project| project.nil? ? {} : { :conditions => { :project_id => project.id } } }
  named_scope :for_company, lambda { |company| company.nil? ? {} : { :conditions => { :company_id => company.id } } }
  named_scope :reverse_order, :order => "time_slices.date DESC, time_slices.id DESC"
  named_scope :from_date, lambda { |date| date.nil? ? {} : { :conditions => [ "time_slices.date >= ?", date ] } }
  named_scope :until_date, lambda { |date| date.nil? ? {} : { :conditions => [ "time_slices.date <= ?", date ] } }
  
  def hours
    elapsed_time.to_s(:hours)
  end
  
  def hours=(value)
    self.elapsed_time = ElapsedTime.hours(value)
  end
  
  def assignment
    @assignment ||= Assignment.find_by_user_id_and_task_id(user_id, task_id) if user_id && task_id
  end
  
protected
  def fill_in_project_and_company
    self.project = self.task.project if task || task_id
    self.company = self.project.company if project || project_id
  end

  def check_if_billable
    self.billable = task.billable? if self.billable.nil? && task
    true
  end

  def update_activity_time
    if minutes_changed? || billable_changed? || new_record?
      counters = { :total_minutes => minutes_changed? ? minutes - (minutes_was || 0) : 0 }
      if billable_changed? && !new_record?
        counters[:billable_minutes] = billable? ? minutes : (minutes_changed? ? -(minutes_was || 0) : -minutes)
      elsif billable?
        counters[:billable_minutes] = counters[:total_minutes]
      end
      Assignment.update_counters assignment.id, counters
    end
  end
  
  def remove_activity_time
    counters = { :total_minutes => -minutes }
    if billable?
      counters[:billable_minutes] = -minutes
    end
    Assignment.update_counters assignment.id, counters
  end
end
