# Shared statefulness stuff for projects, task lists, tasks and assignments.
#--
# TODO hooks back into class for event transitions.
module Statefulness
  def self.included(base)
    base.instance_eval do
      include Stateful
      stateful :current do
        state :active do |state|
          state.event :complete, :to => :completed
          state.event :delete, :to => :deleted
        end
        state :completed do |state|
          state.event :delete, :to => :deleted
        end
        state :deleted
      end
    end
  end
  
  def active?
    currently? :active
  end
  
  def completed?
    currently? :completed
  end
  
  def deleted?
    currently? :deleted
  end
  
  def currently?(state)
    current.state.name == state.to_sym
  end
end

module Stateful #:nodoc:
  class State #:nodoc:
    def to_sym
      name.to_sym
    end
  end
end
