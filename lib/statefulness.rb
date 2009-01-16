# Shared statefulness stuff for projects, task lists, tasks and assignments.
#--
# TODO hooks back into class for event transitions.
module Statefulness
  def self.included(base)
    base.instance_eval do
      include Stateful
      
      stateful :current do
        state :open do |state|
          state.event :complete, :to => :completed
          state.event :delete, :to => :deleted
        end
        state :completed do |state|
          state.event :reopen, :to => :open
          state.event :delete, :to => :deleted
        end
        state :deleted do |state|
          # TODO save pre-deletion state somewhere?
          state.event :undelete, :to => :open
        end
        
        each_event do |event|
          event.requires :valid?
          event.requires(:permission) do |t|
            method_name = :"can_#{event.name}?"
            !t.receiver.respond_to?(method_name) || (t.receiver.send(method_name) != false)
          end
          event.execute do |t|
            method_name = :"on_#{event.name}"
            t.receiver.send method_name if t.receiver.respond_to? method_name
          end
          event.after :save!
        end
      end
    end
    
    # These method definitions are needed so that event.requires and event.after can function correctly above.
    %w(valid? save!).each do |method_name|
      method_name =~ /^([^\!\?]*)([\?\!]?)$/
      with, without = :"#{$1}_with_statefulness#{$2}", :"#{$1}_without_statefulness#{$2}"
      base.send(:define_method, with) { |*args| send without }
      base.send :alias_method_chain, method_name, :statefulness
    end
  end
  
  def open?
    currently? :open
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
