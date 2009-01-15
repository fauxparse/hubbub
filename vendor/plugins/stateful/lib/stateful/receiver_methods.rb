# Note: see Stateful::Binding if you're after instance methods.

module Stateful
  # This adds the :stateful class method to the 'receiver' - the model
  # including Stateful - which allows specifications to be defined
  # within a block in the receiver, or returns a specification if
  # called without a block.
  #
  # calling MyModel.stateful() without a block will return the default
  # specification for the class (named [MyModel, :default]).
  #
  # MyModel.stateful( :snoo ) will return the specification named
  # [MyModel, :snoo].
  #
  # MyModel.stateful( SomeModel, :fizz) will return the specification
  # called [SomeModel, :fizz].

  module ModelClassMethods

    def stateful( *args,
                  &block )

      options     = args.extract_options!.symbolize_keys!
      name        = nil
      default_label = Stateful::Binding::DEFAULT

      name = case args.map(&:class)
             when []         : [ self, default_label ]
             when [ Symbol ] : [ self, args.first    ]
             else
               raise ArgumentError.new( args )
             end
      if specification = Stateful.specify( *name, &block )
        specification.bind_to_class( self, name.last )
      end
      specification
    end
  end  # ModelClassMethods

  def self.included receiver
    receiver.extend  ModelClassMethods
    # receiver.send :include, ModelInstanceMethods
  end

end
