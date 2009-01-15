require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

describe 'Stateful::Hooks' do
  include SpecHelper

  before do
    Stateful.reset!
    @spec = Stateful.specify do
      state :one do |s|
        s.event :twoify, :to => :two
      end
      state :two
    end

    @eh = Stateful::Hooks::EventHooks.new
    @ehc = @eh.class
    @sh = Stateful::Hooks::StateHooks.new
    @shc = @sh.class
    @s = @spec.states.first
    @e = @spec.states.first.events.first
  end

  after do
    Stateful.reset!
  end

  describe "StateHooks" do
    describe "class" do
      it "should have the correct hook names for a State" do
        h = Stateful::Hooks::StateHooks
        h.should respond_to('hook_names')
        h.hook_names.should == [:entry, :exit]
      end

      it "should have a before_h, h, and after_h slot for each hook" do
        h = Stateful::Hooks::StateHooks
        h.should respond_to('slot_names')
        h.slot_names.length.should == h.hook_names.length * 3
      end

      it "should have a bunch of slot names" do
        h = Stateful::Hooks::StateHooks
        h.slot_names.should ==  [:before_entry,
                                 :entry,
                                 :after_entry,
                                 :before_exit,
                                 :exit,
                                 :after_exit]
      end
    end

    describe "instance" do

      describe "run" do
        it "should run all hook slots for the hook_name"

        it "should run before_* first"
        it "should run * second"
        it "should run after_* last"
      end

      describe "add" do
        it "should have an add method" do
          @sh.should respond_to('add')
        end

        it "should add a symbol to the named hook slot" do
          @sh.add :entry, :fart
          @sh.entry.should == :fart
          @sh.add :before_entry, :whistle
          @sh.before_entry.should == :whistle
        end

        it "should add a proc to the named hook slot" do
          proc = proc { true }
          @sh.add :entry, &proc
          @sh.entry.should == proc
        end

        it "should not add other kinds of things to the named hook slot" do
          lambda { @sh.add :entry, "nope" }.should raise_error( ArgumentError )
          lambda { @sh.add :entry, 6 }.should raise_error( ArgumentError )
          lambda { @sh.add :entry, nil }.should raise_error( ArgumentError )
        end

      end
    end
  end

  describe "State" do
    it "should have a Hooks" do
      @s.hooks.should_not be_nil
      @s.hooks.should be_kind_of( Stateful::Hooks::StateHooks )
    end

    it "should have a method for each hook" do
      @s.should respond_to('entry')
      @s.should respond_to('exit')
    end

    it "should have a method for before / after for each hook" do
      @s.should respond_to('before_entry')
      @s.should respond_to('before_exit')
      @s.should respond_to('after_entry')
      @s.should respond_to('after_exit')
    end
  end

  describe "Event" do
    it "should have a Hooks" do
      @e.hooks.should_not be_nil
      @e.hooks.should be_kind_of( Stateful::Hooks::EventHooks )
    end

    it "should have a method for each hook" do
      %w/before during execute after/.each do |m|
        @e.should respond_to( m )
      end
    end

    it "should have a method for before / after for each hook" do
      %w/before during execute after/.each do |h|
        ['before_', '', 'after_'].each do |s|
          @e.should respond_to( "#{s}#{h}" )
        end
      end
    end
  end
end
