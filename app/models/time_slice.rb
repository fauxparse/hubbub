class TimeSlice < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity, :polymorphic => true

  default_value_for :minutes, 0
  validates_presence_of :user_id, :activity_id, :minutes
  
  before_validation :check_if_billable
  before_save :update_activity_time, :if => :caches_minutes_on_activity?
  before_destroy :remove_activity_time, :if => :caches_minutes_on_activity?
  
protected
  def check_if_billable
    self.billable = activity.respond_to?(:billable?) && activity.billable? if self.billable.nil? && activity
  end

  def update_activity_time
    if minutes_changed? || billable_changed? || new_record?
      counters = { :total_minutes => minutes_changed? ? minutes - (minutes_was || 0) : 0 }
      if billable_changed?
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
end
