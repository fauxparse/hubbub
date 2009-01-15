module Stateful
  class Binding

    include Stateful::Args

    @@bindings = Hash.new { |h, k| h[k]= Hash.new }

    DEFAULT = :stateful

    attr_reader :specification, :klass, :accessor_name, :field_name,
                :meta, :methods_defined

    # Stateful::Binding[ MyModel, :workflow ] will returns the Binding
    # for MyModel with the :worflow accessor method name.
    def self.[] klass, accessor_name = nil
      raise( ArgumentError.new( klass )) unless @@bindings[ klass ]
      if accessor_name
        @@bindings[ klass ][ accessor_name ]
      else
        @@bindings[ klass ][ DEFAULT ]
      end
    end

    def initialize( specification,
                    klass,
                    accessor_name = DEFAULT,
                    field_name    = nil,
                    options       = { :meta => { }})

      assert_argument_types( specification => Stateful::Specification,
                             klass         => Class,
                             accessor_name => Symbol,
                             field_name    => [ NilClass, String, Symbol ] )

      @specification              = specification
      @klass                      = klass
      @accessor_name              = accessor_name
      @meta                       = options.delete( :meta ) || { }

      @@bindings[@klass]||= { }
      @@bindings[@klass][accessor_name] = self # clobbers existing
      set_field_name( field_name )
      bind!
      self
    end

    # active record field, or instance variable, name to store state
    def field_name
      @field_name || set_field_name( )
    end

    def set_field_name fn = nil
      fn = fn.to_s
      if fn.nil? || fn.blank?
        fn = @accessor_name.to_s.downcase.tr(' ', '_') + "_state"
      end
      @field_name    = fn
    end
    alias_method :field_name=, :set_field_name

    # defines an instance method to access the Stateful::Instance
    def define_accessor_method!
      binding     = self
      method_name = @accessor_name
      ivar_name   = "@#{accessor_name}"

      @klass.class_eval do
        define_method method_name do
          ivar = instance_variable_get( ivar_name ) ||
            instance_variable_set( ivar_name, Stateful.new( binding, self ))
        end
      end
    end

    # given an event_name :die, target_state_name :dead and an
    # @accessor_name of receiver.stateful, defines a method
    # receiver.die( *args ) ; equivalent to
    # receiver.stateful.trigger( :die, :dead, args)

    def define_simple_event_methods! event_name, target_state_name
      @event_methods    ||= []
      instance            = @accessor_name
      event_methods       = @event_methods
      @klass.class_eval do
        { :trigger     => event_name,
          :can_trigger => "#{event_name}?"}.each do |mcall, mdef|
          if !method_defined?( mdef )
            define_method mdef do |*args|
              send( instance ).send( mcall,
                                     event_name,
                                     target_state_name,
                                     args )
            end
            event_methods << mdef
          end
        end
      end
    end

    # If this is an ActiveRecord object, we need to call the Stateful
    # accessor method before create to ensure the database record
    # has the default value written to its stateful column - otherwise
    # we'd need to repeat ourselves by adding a default value to the SQL
    # table definition for the stateful field.
    def add_before_create_hook!
      return unless active_record?
      method_name = @accessor_name.to_sym
      @klass.class_eval do
        before_create method_name
      end
    end

    def define_complex_event_methods! *a
      raise NotImplementedError, "Event methods for events with multiple targets"
    end

    protected

    # yields an event_name and an array of target states
    # helper method for bind!
    def target_states_by_event_name &block
      specification.all_events.group_by(&:name).
        each do |event_name, evts|
        # ignore events with dynamic targets
        evts = evts.select { |e| e.static_targets? }
        target_states = evts.map do |e|
          e.target_states
        end.flatten.uniq
        yield event_name, target_states
      end
    end

    public

    # binds to @klass, adding an accessor method and, optionally,
    # event trigger methods.
    #
    # for each action name, is there only one possible target state?
    # if so, we can make an event trigger method with the event's
    # name; otherwise, we can either
    #   a) define no method, and use e.g. receiver.stateful.trigger()
    #   b) define several methods whose names are a composite of the
    #      event's name and the target state, eg "#{evt}_to_#{targ}"
    #   c) define a single method which takes the target state as an
    #      argument

    # If the target class is an ActiveRecord object, also add a
    # before_create hook to call the accessor method, ensuring
    # that the default value of the field is initialized.

    def bind!( define_event_methods = true )
      define_accessor_method!
      add_before_create_hook!
      return unless define_event_methods
      target_states_by_event_name do |e_name, arr_s|
        if arr_s.length == 1
          define_simple_event_methods!( e_name, arr_s.first.name )
        else
          # define_complex_event_methods!( e_name, targs )
        end
      end
      # return the list of event methods which were defined on the receiver
      @event_methods
    end

    private

    def active_record?
      ar_name = "ActiveRecord"
      return false unless Object.const_defined?( ar_name )
      klass.ancestors.include? Object.const_get( ar_name ).const_get('Base')
    end

    def active_record_field?
      active_record? && klass.columns.map(&:name).include?( field_name().to_s )
    end

    def column_name
      if active_record_field?
        field_name().to_s
      else
        nil
      end
    end

  end # Binding
end

