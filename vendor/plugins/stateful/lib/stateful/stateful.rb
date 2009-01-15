#!/usr/bin/env ruby
require 'rubygems'
require 'active_support'
require 'active_record'

module Stateful

  class << self

    include Stateful::Args

    def [] *args
      Specification[*args]
    end

    def []= *args
      Specification.send( "[]=", *args )
    end

    def specifications
      Specification.specifications
    end

    # SPECME
    def specify( *args, &block )
      options    = args.extract_options!.symbolize_keys!
      name       = Specification.to_name( *args ) || raise( args.inspect )
      field_name = options.delete( :field_name )

      if block_given?
        if spec = self[ *name ]
          spec.load_specification( &block )
        else
          self[ *name ]= Specification.new( name, options, &block )
        end
        if name.first != Specification
          Stateful::Binding.new( self[ *name ], name.first, name.last, field_name )
        end
      end
      self[ *name ]
    end

    # this is called from the receiver's accessor method when it is first called.
    def new( binding, receiver )
      specification = binding.specification
      if specification.states.empty?
        raise IllegalState.new( nil )
      else
        Instance.new( binding, receiver )
      end
    end

    def reset!
      Stateful::Specification.reset!
    end


  end

end
