module Stateful

  class Error             < Exception
  end

  class MissingStateField < Error
  end

  class IllegalTransition < Error
  end

  class IllegalEvent      < Error
    attr_reader :event_name

    def initialize( event_name, message = event_name )
      @event_name = event_name
      super message
    end
  end

  class IllegalState      < Error
   attr_reader :state_name

    def initialize( state_name, message = state_name )
      @state_name = state_name
      super message
    end

    def to_s
      super + " '#{@state_name }'"
    end


    def inspect
      to_s
    end
  end

  class TransitionHalted < Error

    attr_reader :transition, :message, :source
    def initialize( transition, message, source )
      @transition = transition
      @message    = message
      @source     = source
    end

    def to_s
      i = transition.origin.name
      e = transition.event.name
      f = transition.target.name
      "[ TransitionHalted : [#{i}]->[#{e}]->[#{f}] #{message} ]"
    end

  end
end
