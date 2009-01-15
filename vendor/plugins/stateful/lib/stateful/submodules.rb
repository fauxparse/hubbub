module Stateful
 #  module ArgMethods
 #
 #    def match ( *t )
 #      t.each_with_index do |klasses, i|
 #        next unless a = self[i]
 #        if !klasses.to_a.any? { |k| a.is_a? k }
 #          die( "Wrong class #{a.class} for #{a} #{klasses.to_a.inspect}")
 #        end
 #      end
 #    end
 #
 #    def must message, &block
 #      die( message ) unless yield( self )
 #    end
 #
 #    def die message, *args
 #      raise ArgumentError.new( "#{message} :: #{self.inspect} :: #{args.inspect}" )
 #    end
 #  end

  module Args

 #    def argify(a)
 #      a = a.extend ArgMethods
 #    end
 #
 #    def self.included k
 #      k.extend Stateful::Args
 #    end
 #
    def raise_argument_error( received, expected )
      raise ArgumentError.new( "#{received.inspect} received, but expecting #{expected.inspect}")
    end

    alias_method :bad_arg, :raise_argument_error

    def assert_argument_types mapping = { }
      mapping.each do | arg, klasses |
        if klasses.is_a?( Array )
          raise_argument_error( arg, klasses ) unless klasses.include?( arg.class )
        else
          raise_argument_error( arg, klasses ) unless arg.is_a?( klasses )
        end
      end
    end

  end  # Args

  module ItemsMatchingOptions

    def subset( options, method_name = :name )
      match_opts = extract_match_options( options )
      bad_opts   = match_opts.values.flatten.select do |sym|
        !self.map(&method_name).include?( sym )
      end
      raise ArgumentError.new( bad_opts.inspect ) unless bad_opts.empty?
      if only = match_opts[:only]
        select { |e| only.include?( e.send( method_name )) }
      elsif except = match_opts[:except]
        reject { |e| except.include?( e.send( method_name )) }
      else
        self
      end
    end

    def extract_match_options( options )
      options.symbolize_keys!
      match_opts = { }
      if only = options.delete(:only)
        match_opts[:only] = only.is_a?( Array ) ? only.flatten : [only]
      end
      if except = options.delete(:except)
        match_opts[:except] = except.is_a?( Array ) ? except.flatten : [except]
      end
      raise ArgumentError.new  if only && except
      match_opts
    end

    def items_matching( items, options )
      items = items.extend( ItemsMatchingOptions ).subset( options )
      items.each do |item|
        yield item if block_given?
      end
    end

    def events_matching( options )
      items_matching @specification.all_events, options
    end

    def states_matching( options )
      items_matching @specification.states, options
    end
  end  # ItemsMatchingOptions

  module ArrayNameAccessor
    def []( index )
      begin
        super( index )
      rescue TypeError
        self.detect do |i|
          i.name == index.to_sym
        end if index.respond_to?(:to_sym)
      end
    end
  end  # ArrayNameAccessor

end
