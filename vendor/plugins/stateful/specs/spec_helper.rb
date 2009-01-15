gem     'rspec'
require 'spec'
require 'spec/runner'

Spec::Runner.configure do |config|
  config.mock_with :rr
  # or if that doesn't work due to a version incompatibility
  # config.mock_with RR::Adapters::Rspec
end

# load stateful
require "#{File.dirname(__FILE__)}/../lib/stateful.rb"

# load dependencies
%w/migration/.each do |f|
  require "#{File.dirname(__FILE__)}/#{f}.rb"
end

## Test database config

RAILS_ENV = 'test'
DB_FILE   = File.join( File.dirname( __FILE__), '../db/stateful_spec.db')

#
# methods defined here will be available in specs if SpecHelper is included
#

module SpecHelper

  class Foo
    def ok?( transition )
      true
    end

    def good?( transition )
      true
    end

    include Stateful
  end

  def import( mod )
    mod.constants.each do |c|
      Object.const_set c, mod.const_get( c ) unless Object.const_defined?( c )
    end
  end

  def setup_basic
    import( Stateful )

    Foo.stateful do

      state :one do |s|
        s.event :twoify, :to => :two do |e|
          e.requires :ok?, :message => "ok failed"
          e.requires :good?
        end
      end

      state :two do |s|
        s.event :threeify, :to => :three
      end

      state :three do |s|
        s.event :oneify, :to => :one
      end

    end

    @spec       = Foo.stateful()
    @binding    = Stateful::Binding[ Foo ].inspect
    @obj        = Foo.new()
    @state      = @spec.states[:one]
    @s1         = @spec.states[:one]
    @s2         = @spec.states[:two]
    @s3         = @spec.states[:three]
    @event      = @state.events[:twoify]
    @i          = @obj.stateful()
    @t          = Transition.new( @i, @event, @s2, [] )
  end

  #def c( s )
  #  const = Stateful.const_get( s )
  #  Object.const_set 's', const
  #  const
  #end

  def use_active_record
    require 'active_record'

    ActiveRecord::Base.establish_connection({ "adapter" => "sqlite3",
                                              "dbfile"  => DB_FILE })
    # run_migrations # if ActiveRecord::Base.connection.tables.empty?
  end

  def run_migrations
    require 'active_record'

    ActiveRecord::Base.establish_connection({ "adapter" => "sqlite3",
                                              "dbfile"  => DB_FILE })
    begin
      CreateSpecModels.migrate(:down)
    rescue Exception => e
      puts "Migrate down failed: " + e.inspect
    end
    CreateSpecModels.migrate(:up)
  end

end     # SpecHelper
