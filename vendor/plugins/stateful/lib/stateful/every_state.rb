module Stateful
  class EveryState < State
    include Stateful::ItemsMatchingOptions

    def initialize( specification, options = {} )
      @specification = specification
      @events = [].extend ArrayNameAccessor
      @meta   = options.symbolize_keys![:meta] || { }
    end

    def events_for( state_name )
      events.select do |evt|
        if evt.transitions_to?( state_name )
          false
        elsif o = evt.global_options[:only]
          o.include?(state_name)
        elsif o = evt.global_options[:except]
          !o.include?( state_name )
        else
          true
        end
      end
    end

    def event name, options= { }, &block
      match_opts = extract_match_options( options )
      states_matching( match_opts ).each do |state|
        state.event name, options.dup, &block
        state.events.last.global = true
      end
    end

    def apply_to_matching_states( *args, &block )
      options    = args.extract_options!
      match_opts = extract_match_options( options )
      args << options
      states_matching( match_opts ).each do |s|
        yield s, args
      end
    end


    def on_entry *args, &condition
      apply_to_matching_states( *args ) do |s, clean_args|
        s.add_hook :on_every_entry, *clean_args, &condition
      end
    end

    def on_exit *args, &condition
      apply_to_matching_states( *args ) do |s, clean_args|
        s.add_hook :on_every_exit, *clean_args, &condition
      end
    end

    def to_s
      "[ EveryState: #{name} (#{events.map(&:to_s).join ", "}) ]"
    end
  end
end
