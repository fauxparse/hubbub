require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

# require 'active_record'

module InstanceSpecHelper

end

describe 'Stateful::Instance' do
  include SpecHelper
  include InstanceSpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe "Constructor" do
    before do
      @spec     = Stateful.specify { state :one; state :two }
      @binding  = Stateful::Binding.new( @spec, String )
      @receiver = { }
    end

    it "should raise IllegalState if the specification has no states"

    it "should require a binding" do
      lambda do
        Stateful::Instance.new( "?", @receiver )
      end.should raise_error( ArgumentError )

      lambda do
        Stateful::Instance.new( @binding, @receiver )
      end.should_not raise_error( ArgumentError )
    end

    it "should set its receiver to the one supplied" do
      instance = Stateful::Instance.new( @binding, @receiver )
      instance.receiver.should == @receiver
    end

    it "should set the initial_state if one is provided " do
      instance = Stateful::Instance.new( @binding, @receiver )
      instance.state.name.should == :one

      instance = Stateful::Instance.new( @binding, @receiver, :two )
      instance.state.name.should == :two

      instance = Stateful::Instance.new( @binding, @receiver, @spec.states.last )
      instance.state.name.should == :two
    end

    it "should set_default_state if no initial_state is provided" do
      instance = Stateful::Instance.new( @binding, @receiver )
      instance.state.name.should == :one

      @receiver.stateful_state = 'two'
      instance = Stateful::Instance.new( @binding, @receiver )
      instance.state.name.should == :two

      @receiver.stateful_state = 'tom_cruise'
      lambda do
        instance = Stateful::Instance.new( @binding, @receiver )
      end.should raise_error( Stateful::IllegalState )
    end

  end

  describe "Instance methods" do
    before do
      @spec     = Stateful.specify do
        state :one do |s|
          s.event :twoify, :to => :two
        end
        state :two
      end
      @binding  = Stateful::Binding.new( @spec, String )
      @receiver = { }
      @instance = Stateful::Instance.new( @binding, @receiver )
    end

    describe "halt" do
      it "should return the current_transition's last_halt"
    end

    describe "begin_transition" do
      it "should take an Event or event name as a Symbol as its first argument" do
        lambda do
          @instance.begin_transition( @spec.states.first.events.first, :b, [] )
        end.should_not raise_error( ArgumentError )

        lambda do
          @instance.begin_transition( @spec.states.first.events.first, :b)
        end.should raise_error( ArgumentError )

        lambda do
          @instance.begin_transition( @spec.states.first, :b )
        end.should raise_error( ArgumentError )

        lambda do
          @instance.begin_transition( "a", :b, [] )
        end.should raise_error( ArgumentError )


        lambda do
          @instance.begin_transition( :a, :b, [] )
        end.should_not raise_error( ArgumentError )
      end

      it "should take a target State or state name as a Symbol as its 2nd argument" do
        lambda do
          @instance.begin_transition( :a, @spec.states.first.events.first, [] )
        end.should raise_error( ArgumentError )

        lambda do
          @instance.begin_transition( :a, "snoo", [] )
        end.should raise_error( ArgumentError )

        lambda do
          @instance.begin_transition( :a, @spec.states.first, [] )
        end.should_not raise_error( ArgumentError )

        lambda do
          @instance.begin_transition( :a, :b, [] )
        end.should_not raise_error( ArgumentError )
      end
    end

    describe "abort_transition" do
    end
    describe "transition!" do
    end
    describe "current_transition" do
    end
    describe "state" do
    end
    describe "halted?" do
    end
    describe "reload_state!" do
    end
    describe "trigger_event" do
    end
    describe "event_triggerable?" do
    end
    describe "state_field_value" do
    end
    describe "set_state_field_value" do
    end
    describe "set_default_state" do
    end
    describe "set_state" do
    end
  end

end
