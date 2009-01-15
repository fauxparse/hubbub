module Stateful
  class Transition

    # TODO:
    # include Stateful

    STATES  = %w/new executable before on_exit during on_entry execute after/.
                                                                  map(&:to_sym)

    def next()
      @state = STATE[ STATES.index(@state) + 1 ]
    end

    def state=( s )
      @state = STATE[ STATES.index( s ) ]
    end

    include Stateful::Args

    attr_reader :binding, :origin, :target, :event, :meta, :args, :curr_hook, :instance

    def initialize( instance,
                    event,
                    target,
                    args          = [],
                    options       = {} )

      assert_argument_types( instance      => Stateful::Instance,
                             event         => [Stateful::Event, Symbol],
                             target        => [Stateful::State, Symbol],
                             args          => Array,
                             options       => Hash )

      if event.is_a?( Symbol )
        event = instance.events[ event ]
        raise ArgumentError, event unless event.is_a?( Stateful::Event )
      end

      if target.is_a?( Symbol )
        target = event.target_states[ target ]
        raise ArgumentError, event unless target.is_a?( Stateful::State )
      end

      @instance      = instance
      @event         = event
      @origin        = instance.state
      @target        = target
      @meta          = options.symbolize_keys![:meta] || { }
      @curr_hook     = nil
      @args          = args
      @state         = STATES.first
      @halteds       = []

      verify!
    end

    def verify!
      if !specification.states.include?( origin )
        raise ArgumentError, origin
      end
      if !specification.states.include?( target )
        raise ArgumentError, target
      end
      if !instance.events.map(&:name).include?( event.name )
        raise ArgumentError, event
      end
      if !event.transitions_to?( target )
        raise ArgumentError, "#{event.name} doesn't go to #{ target }"
      end
      self
    end

    def specification
      @instance.specification
    end

    def binding
      @instance.binding
    end

    def receiver
      @instance.receiver
    end

    def obj
      receiver
    end

    def run_hook( runner, hook_name )
      @curr_hook = hook_name
      state=( hook_name )
      runner.hooks.run( hook_name, self)
    end

    def commit!
      state=( :commit )
      @instance.commit_current_transition( )
    end

    def execute( &block )
      if executable?
        state=( :executable )
        begin
          run_hook( @event,  :before   )
          run_hook( @origin, :on_exit  )
          run_hook( @event,  :during   )
          run_hook( @target, :on_entry )

          @instance.finalize_transition

          run_hook( @event,  :execute  )
        rescue TransitionHalted => halt_e
          halted_with( halt_e )

          # rollback if reqd
        end
        run_hook(   @event,  :after    )
        @completed = true
        true
      else
        # halted_with TransitionHalted.new( self,
        #                                 condition_failure_messages() )
        false
      end
    end

    def condition_failure_messages()
      if executable?
        []
      else
        exceptions.map(&:message)
      end
    end

    def executable?( &block )
      begin
        event.evaluate_requirements( self )
        true
      rescue TransitionHalted => halt_e
        halted_with halt_e
        false
      end
    end

    def halt!( message )
      raise TransitionHalted.new( self, message, self )
    end

    def halted_with e
      # raise "Already Halted" if halted?
      assert_argument_types( e => Stateful::TransitionHalted )
      @halteds << e
      e
    end

    def halt_messages
      exceptions.map(&:message)
    end

    def exceptions
      @halteds
    end
    alias_method :halts, :exceptions

    def last_halt
      @halteds.last
    end

    def started?
      !! @started
    end

    def halted?
      !! last_halt
    end

    def completed?
      !! @completed
    end
    alias_method :complete?, :completed?

    def test_only?
      !! @test_only
    end

    def finished?
      halted? || completed?
    end

    def active?
      started? && !finished?
    end

  end

  # we use this when we're just checking if a transition is possible
  # class TestTransition < Stateful::Transition
  # end

end
