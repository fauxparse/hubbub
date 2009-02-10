class TimeSlice < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity, :polymorphic => true
  delegate :task, :to => :activity

  composed_of :elapsed_time, :mapping => %w(minutes minutes)
  default_value_for(:date) { |record| Date.today }
  validates_presence_of :user_id, :activity_id, :minutes, :date

  before_validation :check_if_billable
  after_save :update_activity_time, :if => :caches_minutes_on_activity?
  before_destroy :remove_activity_time, :if => :caches_minutes_on_activity?
  
  named_scope :for_user, lambda { |user| user.nil? ? {} : { :conditions => { :user_id => user.id } } }
  named_scope :for_task, lambda { |task| task.nil? ? {} : { :conditions => [ "(time_slices.activity_type = 'Task' AND time_slices.activity_id = ?) OR (time_slices.activity_type = 'Assignment' AND time_slices.activity_id IN (?))", task.id, task.assignment_ids ] } }
  named_scope :reverse_order, :order => "time_slices.date DESC, time_slices.id DESC"
  named_scope :from_date, lambda { |date| date.nil? ? {} : { :conditions => [ "time_slices.date >= ?", date ] } }
  named_scope :until_date, lambda { |date| date.nil? ? {} : { :conditions => [ "time_slices.date <= ?", date ] } }
  
  def hours
    elapsed_time.to_s(:hours)
  end
  
  def hours=(value)
    self.elapsed_time = ElapsedTime.hours(value)
  end
  
protected
  def check_if_billable
    self.billable = activity.respond_to?(:billable?) && activity.billable? if self.billable.nil? && activity
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
      Assignment.update_counters activity_id, counters
    end
  end
  
  def remove_activity_time
    counters = { :total_minutes => -minutes }
    if billable?
      counters[:billable_minutes] = -minutes
    end
    Assignment.update_counters activity_id, counters
  end
  
  def caches_minutes_on_activity?
    activity_type == "Assignment"
  end
  
  def before_create
    if activity.is_a?(Task) && (assignment = activity.assignments.detect { |a| a.user_id == user_id })
      self.activity = assignment
    end
  end
end
