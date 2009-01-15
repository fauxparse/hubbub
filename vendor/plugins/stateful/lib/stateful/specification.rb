module Stateful

  class Specification
    include Stateful::Args

    @@specs = ActiveSupport::OrderedHash.new()

    DEFAULT_LABEL   = :default

    attr_reader   :states, :meta, :every_state, :every_event, :name

    def initialize( name,
                    options = { },
                    &specification )

      options.symbolize_keys!

      @name           = name
      @meta           = options[:meta]  || { }
      @states         = [].extend( ArrayNameAccessor )

      # @every_state    = EveryState.new( self )
      # @every_event    = EveryEvent.new( self )

      validate_name!
      load_specification( &specification )
      validate!
    end

    # Note - if there is already a binding, this will clobber it.
    # Is that really what we want? I think so ...

    def bind_to_class( klass, accessor_name, field_name = nil )
      Binding.new( self, klass, accessor_name, field_name )
    end

    def all_events
      states.map(&:events).flatten.uniq.sort_by do |e|
        e.name.to_s
      end
    end

    def load_specification &spec
      instance_eval( &spec )
      validate!
    end

    def validate_name!
      self.class.validate_name( @name ) || raise( @name.inspect )
    end

    # does not check events with dynamic targets / Procs
    def validate_event_targets!
      static_target_events = all_events.select { |e| e.static_targets? }
      bad_targets          = static_target_events.map(&:target_states).flatten.uniq.
        reject { |ts| states.include?(ts) }
      raise IllegalState.new( bad_targets) unless bad_targets.empty?
    end

    def validate!
      validate_name!
      validate_event_targets!
    end

    def state *args, &block
      if s = states[ args.first ]
      else
        args.unshift( self )
        s = State.new( *args )
        self.states << s
      end
      yield s if block_given?
    end

    def each_state &block
      if block_given?
        states.each do |s|
          yield s
        end
      end
      states
    end
    alias_method :every_state, :each_state

    def each_event &block
      if block_given?
        all_events.each do |e|
          yield e
        end
      end
      all_events
    end
    alias_method :every_event, :each_event

    def to_hash
      h = { }
      states.each do |s|
        k1 = s.name
        h[k1] = { }
        s.events.each do |e|
          k2 = e.name
          h[k1][k2] = e.transitions_to
        end
      end
      h
    end

    def to_s
      "<Stateful::Spec #{name.inspect} :: #{states.map(&:to_s).inspect}"
    end

    def inspect
      to_s
    end

    def to_json *args
      to_hash.to_json
    end

    #
    # Class Methods

    def self.specifications
      @@specs
    end

    def self.to_name *a
      name = nil
      if validate_name(a) # [MyClass, :mylabel]
        name = a
      elsif a.length == 0
        name = [self, DEFAULT_LABEL]
      elsif a.length == 1
        arg = a.first
        if arg.is_a?( Class )
          name = [arg, DEFAULT_LABEL]
        elsif [Symbol].include?( arg.class )
          name = [self, arg]
        end
      end
      raise name.inspect unless name.nil? || validate_name( name )
      name
    end

    def self.validate_name n
      Array     === n &&
        2       ==  n.length &&
        Class   === n.first &&
        Symbol  === n.last &&
        n
    end

    def self.find klass, label
      @@specs[ klass ] ||= ActiveSupport::OrderedHash.new( )
      @@specs[ klass ][ label ]
    end

    def self.reset!
      @@specs = ActiveSupport::OrderedHash.new( )
    end

    def self.[] *a, &block
      name = to_name( *a ) || raise( ArgumentError.new( a.inspect ))
      s = find *name
      yield s if block_given?
      s
    end

    def self.[]= *args
      spec = args.pop()
      raise ArgumentError.new() unless spec.is_a?( self )
      raise ArgumentError.new() unless validate_name( args )
      @@specs[ args.first]  ||= ActiveSupport::OrderedHash.new( )
      @@specs[ args.first ][ args.last ] = spec
    end

  end
end
