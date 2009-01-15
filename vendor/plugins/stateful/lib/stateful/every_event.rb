module Stateful
  class EveryEvent

    include Stateful::ItemsMatchingOptions

    def initialize( specification, options = {} )
      @specification = specification
      @meta           = options.symbolize_keys![:meta] || { }
      @requirements   = [].extend ArrayNameAccessor
      @satisfiers     = [].extend ArrayNameAccessor
    end

    def apply_to_matching_events( *args, &block )
      options    = args.extract_options!
      match_opts = extract_match_options( options )
      args << options
      events_matching( match_opts ).each do |evt|
        yield evt, args
      end
    end

    def requires *args, &condition
      apply_to_matching_events( *args ) do |evt, clean_args|
        evt.requires( *clean_args, &condition )
      end
    end

    def satisfy *args, &condition
      apply_to_matching_events( *args ) do |evt, clean_args|
        evt.satisfy( *clean_args, &condition )
      end
    end

    def before *args, &condition
      apply_to_matching_events( *args ) do |evt, clean_args|
        evt.add_hook :every_before, *clean_args, &condition
      end
    end

    def execute *args, &condition
      apply_to_matching_events( *args ) do |evt, clean_args|
        evt.add_hook :every_execute, *clean_args, &condition
      end
    end

    def after *args, &condition
      apply_to_matching_events( *args ) do |evt, clean_args|
        evt.add_hook :every_after, *clean_args, &condition
      end
    end

    private

    def set_global_options obj, options
      obj.global         = true
      obj.global_options = { }

      if only = options.delete( :only )
        obj.global_options[:only] = only.is_a?( Array ) ? only.map(&:to_sym) : [ only.to_sym ]
      elsif
        except = options.delete( :except )
        obj.global_options[:except] = except.is_a?( Array ) ? except.map(&:to_sym) : [ except.to_sym ]
      end
    end

    def rules_for( collection, event )
      collection.select do |i|
        if only = i.global_options[:only]
          only.include?( event )
        elsif except = i.global_options[:except]
          !except.include?( event )
        else
          true
        end
      end
    end
  end
end
