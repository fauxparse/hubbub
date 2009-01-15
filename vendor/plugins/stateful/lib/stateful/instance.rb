module Stateful

  class Instance
    include Stateful::Args

    attr_reader :states, :meta, :receiver, :specification, :state_name, :binding
    attr_reader :accessor_method_name
    attr_reader :transitions

    def initialize( binding, receiver, initial_state = nil )
      @binding        = binding
      @receiver       = receiver
      @meta           = { }
      @transitions    = []

      assert_argument_types( binding => Stateful::Binding )
      initial_state ? set_state( initial_state ) : set_default_state
    end

    def begin_transition( evt, to, args )

      # assert_argument_types( evt => [Stateful::Event, Symbol],
      #                        to  => [Stateful::State, Symbol] )
      #
      # e = evt.is_a?( Stateful::Event ) ? state.events[ evt.name ] : state.events[ evt ]
      # s = to.is_a?( Stateful::State ) ? to : e.target_states.detect { |st| st.name == to }
      # t = Stateful::Transition.new( self, e, s, args )

#      raise [self, evt, to, args].map { |x| x.to_s + "\n\n" }.inspect
      @transitions << Stateful::Transition.new( self, evt, to, args )
    end

    def abort_transition
      @transition = nil
    end

    # runs the current transition
    def transition! &block
      raise "No Current Transition" unless current_transition
      current_transition.execute
      #       set_state current_transition.target
      true
    end

    # called by the transition : updates state to the current_transition's target
    def finalize_transition
      set_state current_transition.target
    end

    def current_transition
      t = @transitions.last
      t if t && ! t.completed?
    end

    def state
      states[ @state_name ]
    end

    [ :states, :all_events, :every_event, :every_state ].each do |m|
      define_method m do |*args|
        specification.send(m, *args)
      end
    end

    [ :field_name, :column_name, :specification, :active_record?, :active_record_field? ].each do |m|
      define_method m do |*args|
        @binding.send(m, *args)
      end
    end

    def halt
      current_transition && current_transition.last_halt
    end

    def halted?
      !! current_transition && current_transition.halted?
    end

    def reload_state!
      set_default_state()
    end

    def halt_messages
      current_transition.halt_messages
    end

    def trigger_event evt, to, args = [], &block
      begin_transition( evt, to, args )
      current_transition.execute &block
      if current_transition
        # it halted
        nil
      else
        true
      end
    end
    alias_method :trigger, :trigger_event

    def event_triggerable? evt, to, args = []
      event_requirement_failure_messages( evt, to, args = [] ).empty?
    end


    def event_requirement_failure_messages evt, to, args = []
      test = Stateful::Transition.new( self, evt, to, args )
      test.condition_failure_messages
    end

    # events for the current state; any with dynamic_targets are collapsed into a set of static
    def events
      state.events.map { |e| e.dynamic_targets? ? e.to_instance( self ) : e }.extend ArrayNameAccessor
    end

    alias_method :can_trigger?, :event_triggerable?

    def state_field_value
      if active_record_field?
        v = receiver.read_attribute( field_name )
        v unless v.blank?
      elsif receiver.respond_to?( field_name )
        receiver.send( field_name)
      else
        false
      end
    end

    private

    def set_state_field_value( value = @state_name )
      fn = field_name
      if active_record_field?
        receiver.write_attribute( field_name, value.to_s )
      elsif receiver.respond_to?( "#{fn}=" )
        receiver.send( "#{fn}=", value.to_s )
      elsif !active_record?
        receiver.class.class_eval do
          attr_accessor "#{fn}"
        end
        receiver.send( "#{fn}=", value.to_s )
      else
        raise(MissingStateField.new( fn ))
      end
      value
    end

    def set_default_state
      set_state( state_field_value || states.first )
      set_state_field_value
    end

    def set_state( new_state )
      if new_state.is_a?( Stateful::State )
        @state_name = new_state.name
      elsif states[ new_state ].is_a?( Stateful::State )
        @state_name = states[ new_state ].name
      else
        raise IllegalState.new( "No state #{ new_state.inspect }")
      end
      set_state_field_value( @state_name )
      @state_name
    end

  end

end
