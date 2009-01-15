module Stateful
  class Event
    class Rule
      include Stateful::Args

      attr_reader :condition, :message, :meta, :name

      # TODO - check uniqueness of name / reuse existing

      def set_condition name, &condition
        if block_given?
          @condition = condition
        elsif name.is_a?( Symbol )
          @condition = name
        else
          raise ArgumentError, "No condition supplied: #{ self.class } #{args.inspect}"
        end
      end

      def set_name name
        if name.is_a?( Symbol )
          @name = name
        else
          raise ArgumentError, "Name should be a symbol: #{name.inspect}"
        end
      end

    end  # Rule

    class Requirement < Rule

      attr_reader   :name, :message
      attr_accessor :global, :global_options

      def initialize name, *args, &condition
        options    = args.extract_options!.symbolize_keys!

        set_name( name )
        set_condition( name , &condition )

        raise( ArgumentError, args.inspect ) if args.length != 0
        @message   = options.delete(:message) || default_message( )
        @meta      = options.delete(:meta) || { }

        self
      end

      def default_message
        @name
      end

      def test( transition )
        res = case condition
              when Symbol
                transition.obj.send( condition, transition )
              when Proc
                condition.call( transition )
              else
                raise ArgumentError, "Expected Symbol or Proc: #{ condition }"
              end
        if res
          true
        else
          raise(  TransitionHalted.new( transition, @message, self ) )
        end
      end
    end # Requirement

    class Satisfier < Requirement

      def set_name *args
      end

    end # Satisfier

    class Halter < Requirement

      def evaluate receiver, *args
        ! super( receiver, *args )
      end

      def process_arguments( *args, &condition )
        if args.length == 1 && [String, Symbol, Proc].include?( args.first.class )
          @message = args.shift
        end
        super *args, &condition
        args
      end
    end # Halter
  end   # Event
end     # Stateful
