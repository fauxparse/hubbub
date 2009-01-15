module Stateful
  class Event
    include Stateful::Args
    include Stateful::Hooks::EventMethods

    attr_reader   :name, :initial_state, :meta
    attr_reader   :requirements, :satisfiers
    attr_accessor :global, :global_options, :global_hooks
    attr_accessor :message

    def label
      @message
    end

    def targets
      @targets
    end

    def initialize(name, initial_state, target_states, options = {})
      @name           = name.to_sym
      assert_argument_types( name           => Symbol,
                             initial_state  => Stateful::State,
                             target_states  => [Array, Symbol, Stateful::State, Proc] )

      set_targets( target_states )

      @initial_state          = initial_state
      @meta                   = options.symbolize_keys![:meta] || { }
      @message                = options[:message] || nil
      @requirements           = [].extend ArrayNameAccessor
      @satisfiers             = [].extend ArrayNameAccessor
    end

    def single_target?
      static_targets? && @targets.length == 1
    end

    def static_targets?
      ! dynamic_targets?
    end

    def dynamic_targets?
      @targets.is_a?( Proc )
    end

    def target_state
      raise @targets.inspect unless single_target?
      @targets.first
    end

    def target_state_name
      target_state.name
    end

    def find_state_by_name state_name
      s = @initial_state.specification.states[ state_name ]
      ss = @initial_state.specification.states.map(&:name).inspect

      raise( Stateful::IllegalState.new( state_name )) unless s.is_a?( Stateful::State )
      s
    end

    def target_state_names( obj = nil )
      target_states( obj ).map( &:name )
    end

    def target_states obj = nil
      ts = case @targets
           when Proc
             if obj.nil?
               raise ArgumentError, "Receiver cannot be nil when evaluating dynamic target states"
               # begin
             else
               @targets.call( obj )
               # return
             end
             # raise NotImplementedError, "Proc for target states"
           when Array
             if @targets.all? { |s| s.is_a?( Stateful::State ) }
               @targets
             else
               @targets = @targets.map do |s|
                 s.is_a?( Stateful::State ) ? s : find_state_by_name( s )
               end
             end
           end
      ts.extend ArrayNameAccessor
    end

    def set_targets targets
      if targets.is_a?( Array )
        targets = targets.map do |t|
          case t
          when Symbol
            t
          when Stateful::State
            t.name
          when Proc
            t
          else
            raise ArgumentError, targ
          end
        end
      elsif targets.is_a?( Proc )

          # do nothing
          # raise NotImplementedError, "Proc for target states"

      else
        if targets.is_a?( Symbol )
          targets = [ targets ]
        elsif targets.is_a?( Stateful::State )
          targets = [ targets.name ]
        else
          raise ArgumentError, targets.inspect
        end
        raise targets.inspect if targets.any? { |s| ! s.is_a?(Symbol) }
      end

      @targets = targets
    end

    def verify!
      if target_states.empty?
        raise "No target state"
      end
      if !target_states.each.is_a?( Stateful::State )
        raise target_states.inspect
      end
    end


    def transitions_to?( s )
      if s.is_a?( Stateful::State )
        target_states.include?( s )
      elsif s.is_a?( Symbol )
        target_state_names.include?( s )
      else
        raise s.inspect
        nil
      end
    end

    def evaluate_requirements( t )
      assert_argument_types( t => Stateful::Transition )
      requirements.each do |r|
        r.test( t )
      end
    end

    # conditions
    def satisfy *args, &condition
      self.satisfiers << Satisfier.new( *args, &condition )
    end

    def requires *args, &condition
      self.requirements << Requirement.new( *args, &condition )
    end

    def halt_if( *args, &condition)
      self.requirements << Halter.new( *args, &condition )
    end

    def to_s
      target_names = dynamic_targets? ? '#Proc' : target_state_names.to_a.join(', ')
      "<Event: #{name} => [#{ target_names }]>"
    end

    def inspect
      to_s
    end

    # bit of a dirty hack to support dynamic targets
    # course, when it comes to it we'll prolly need the same for dynamuc messages / labels
    def to_instance( instance )
      raise ArgumentError, "Only an Event with dynamic_targets wants to be instantiated" unless dynamic_targets?
      targs = target_states( instance.receiver )
      Event.new( name, initial_state, targs, { :meta => meta, :message => message } )
    end

    private

  end

end
