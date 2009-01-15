module Stateful

  class State
    attr_reader :name, :events, :meta, :specification

    attr_accessor :message

    def label
      @message
    end

    include Stateful::Args
    include Stateful::Hooks::StateMethods

    def initialize( specification, name, options = {} )
      assert_argument_types( specification => Stateful::Specification,
                             name => Symbol )
      @specification = specification
      @name          = name
      @events        = [].extend ArrayNameAccessor
      @meta          = options.symbolize_keys![:meta] || { }
      @message       = options[:message] || nil
    end

    def event *args, &block
      options        = args.extract_options!.symbolize_keys!
      transitions_to = options.delete(:transitions_to) || options.delete(:to)
      name           = args.shift

      new_event      = Event.new( name, self, transitions_to, options )

      if existing_event = events[name.to_sym]
        events.delete( existing_event ) # TODO - or update it
      end

      if block_given?
        yield new_event
      end

      self.events << new_event
    end

    def events_to
      specification.all_events.select { |e| e.target_states.include?( self ) }
    end

    def to_s
      "<State: #{name} :: #{events.map(&:to_s).join(',')} >"
    end

    def inspect
      to_s
    end

    # defined by hooks
    alias_method :on_entry, :entry
    alias_method :on_exit,  :exit
  end

end
