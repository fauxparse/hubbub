require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

# require 'active_record'

module SpecificationSpecHelper
  def const c , v
    if !Object.const_defined?(c)
      Object.const_set c ,v
    end
  end

  def call_with *a, &block
    meth = a.shift
    SS.send meth, *a, &block
  end

  def fail_with *a, &block
    meth = a.shift
    lambda { SS.send meth, *a, &block }.should raise_error( )
  end

end

describe 'Stateful::Specification' do
  include SpecHelper
  include SpecificationSpecHelper

  before do
    const 'SS', Stateful::Specification
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe "Constructor" do
    it "needs a valid name"
    it "needs a block"

    it "passes the block to load_specification"

  end

  describe "instance methods" do
    before do
      class SpecFoo
        include Stateful
      end

      @spec = Stateful::Specification.new( [String, :spec] ) do
        state :one do |s|
          s.event :twoify, :to => :two
        end
        state :two do |s|
          s.event :threeify, :to => :three
        end
        state :three do |s|
          s.event :oneify, :to => :one
        end
      end

      @receiver = SpecFoo.new
    end

    describe "bind_to_class" do
      before do
        @binding = Stateful::Binding.new( @spec, SpecFoo, :accessor )
      end

      it "should call Binding.new with itself + the arguments provided" do
        mock( Stateful::Binding ).new( @spec, SpecFoo, :accessor, nil )
        mock( Stateful::Binding ).new( @spec, SpecFoo, :accessor, :field_name )
        @spec.bind_to_class( SpecFoo, :accessor )
        @spec.bind_to_class( SpecFoo, :accessor, :field_name)
      end
    end

    describe "each_state" do

      it "should return all states" do
        @spec.each_state.should be_kind_of( Array )
        @spec.each_state.should == @spec.states
      end

      it "should yield each state to a block if given" do
        a = []
        @spec.each_state do |s|
          s.should be_kind_of( Stateful::State )
          a << s
        end
        a.should == @spec.states
      end
    end

    describe "each_event" do

      it "should return all events for the specification" do
        @spec.all_events.should_not be_nil
        @spec.each_event.class.should == Array
        @spec.each_event.should == @spec.all_events
      end

      it "should yield each event to a block if given" do
        a = []
        @spec.each_event do |s|
          s.should be_kind_of( Stateful::Event )
          a << s
        end
        a.should == @spec.all_events
      end

    end

    describe "all_events" do
      it "should return a flat array of all the events from all the states" do
        @spec.all_events.all? { |e| e.is_a?( Stateful::Event) }.should be_true
        @spec.all_events.should_not be_empty
        @spec.all_events.length.should == 3
        @spec.all_events.sort_by { |e| e.name.to_s }.should ==
          @spec.states.map(&:events).flatten.sort_by { |e| e.name.to_s }
      end
    end

    describe "load_specification" do
      it "should call instance eval with the block and then validate!" do
        bl = lambda { }
        mock( @spec ).instance_eval( &bl )
        mock( @spec ).validate!
        @spec.load_specification( &bl )
      end
    end

    describe "state" do
      describe "given an existing state name" do
        it "should return the named State and yield it to the block if given" do
          one = @spec.states[:one]
          @spec.state :one do |s|
            s.should == one
          end
        end
      end
      describe "given a new state name" do
        it "should return a new State and yield it to the block if given" do
          @spec.state :four, :meta => { :number => 4 } do |s|
            s.name.should == :four
            s.meta.should == {  :number => 4 }
          end
        end
      end
    end

    describe "validate!" do
      it "should validate_name! and validate_event_targets!" do
        mock( @spec ).validate_name!
        mock( @spec ).validate_event_targets!
        @spec.validate!
      end
    end

    describe "validate_event_targets!" do
      it "should raise if any events point to states that do not exist" do
        @spec.validate_event_targets!
        mock( @spec.states.first.events.first ).target_states { [:huh?] }
        lambda { @spec.validate_event_targets! }.should raise_error( Stateful::IllegalState )

        rogue_state = Stateful::State.new( @spec, :rogue )
        mock( @spec.states.first.events.first ).target_states { [rogue_state] }
        lambda { @spec.validate_event_targets! }.should raise_error( Stateful::IllegalState )

        mock( @spec.states.first.events.first ).target_states { @spec.states.last }
        lambda { @spec.validate_event_targets! }.should_not raise_error( Stateful::IllegalState )
      end
    end

    describe "validate_name!" do
      it "should call Specification.validate_name( @name ) or die" do
        mock( Stateful::Specification ).validate_name( @spec.name ) { false }
        lambda {  @spec.validate_name! }.should raise_error( )
      end
    end

  end

  describe "Class methods" do
    describe "to_name" do
      it "needs a spec"
    end

    describe "find" do
      it "needs a spec"
    end

    describe "[]" do
      it "should return the named specification from :find"
      it "should yield the named specification to a block given"
    end

    # colour me pedantic
    describe "validate_name" do

      it "should respond to it" do
        SS.should respond_to('[]')
      end

      it "it should allow one argument if it is a class " do
        call_with '[]', String
      end

      it "it should allow one argument if it is a symbol " do
        fail_with '[]', "Hi"
        call_with '[]', :Hi
      end

      it "shouldn't allow allow a numeric or string argument" do
        fail_with '[]', 6
        fail_with '[]', "Six"
        fail_with '[]', "Six", 7
      end

      it "it should not allow 3 or more arguments" do
        fail_with String, :method, :woof
        fail_with String, "thing", "roof"
      end

      it "it should allow no arguments" do
        call_with '[]'
      end

      it "it should allow two arguments if the first is a class and the second a symbol" do
        call_with '[]', String, :string
        fail_with '[]', String, "string"
      end

      it "it should not allow two arguments if the last is not a symbol" do
        fail_with '[]', String, STDIN
        fail_with '[]', String, "6".method(:to_s)
        fail_with '[]', String, lambda { }
      end

      it "it should not allow two arguments if the first is not a class" do
        fail_with '[]', "String", "String"
        fail_with '[]', "String", :string
        fail_with '[]', :string, :string
        fail_with '[]', :string, "string"
        fail_with '[]', [], :o
      end
    end
  end
end
