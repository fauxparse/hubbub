require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

describe 'Stateful::Transition' do
  include SpecHelper

  before do
    Stateful.reset!
    setup_basic()
    @t = @obj.stateful.begin_transition( :twoify, :two, ["hi mum"])
  end

  describe "constructor" do
    describe "requirements" do
      it "should require a final state in the instance specification's states" do
        s = Transition::State.new( @spec, :wizzle  )

        lambda do
          Stateful::Transition.new( @i, @event, s, [])
        end.should raise_error( ArgumentError )

        lambda do
          Stateful::Transition.new( @i, @event, @event.targets.last, [])
        end.should_not raise_error( ArgumentError )
      end

      it "should allow the final state to be supplied as a symbol of the state's name" do
        lambda do
          Stateful::Transition.new( @i, @event, @event.targets.last.name, [])
        end.should_not raise_error( ArgumentError )
      end

      it "should require an event in the instance specification's events" do
        e = Stateful::Event.new( :buh, @s1, @s2 )

        lambda do
          Stateful::Transition.new( @i, @event, s, [])
        end.should_not raise_error( ArgumentError )

        lambda do
          Stateful::Transition.new( @i, e, e.target_states.last, [])
        end.should raise_error( ArgumentError )
      end

      it "should require a final state which is a target of the event" do
        e = Stateful::Event.new( :buh, @s1, @s2 )

        lambda do
          Stateful::Transition.new( @i, @event, @s3, [])
        end.should raise_error( ArgumentError )
      end
    end

    describe "behaviour" do
    end
  end

  describe "instance methods" do
    describe "specification, binding, receiver" do
      it "should call the same method on the instance" do
        %w/specification binding receiver/.each do |m|
          @t.send(m).should == @i.send(m)
        end
      end
    end

    describe "obj" do
      it "should be the instance" do
        @t.obj.should == @obj
      end
    end

    describe "run_hook" do
      it "should call run on the hook and hook_name in its args"
    end

    # e.before
    # s1.exit
    # e.during
    # s2.enter
    # e.execute
    # e.after

    describe "execute" do
      describe "when the transition successfully meets its preconditions" do
        describe "when the transition successfully completes without halting" do

          it "should have curr_hook as :after " do
            @i.transition!
            @t.curr_hook.should == :after
          end

          it "should not be halted?" do
            @i.transition!
            @t.should_not be_halted
          end

          it "should be completed?" do
            @i.transition!
            @t.should be_completed
            @i.state.name.should == :two
          end

          it "should call finalize_transition on the instance" do
            mock( @i ).finalize_transition() { }
            @i.transition!
          end

          it "should change the state of the instance" do
            @i.transition!
            @i.state.name.should == :two
          end
        end

        describe "when the transition halts from an event hook" do
        end

        describe "when the transition halts from a state hook" do
        end

      end
      describe "when the transition halts during its precondition checks" do
        before do
          @t.should be_kind_of( Stateful::Transition )
        end

        it "should halt the transition" do
          mock( @obj ).ok?( @t ) { false }

          @obj.should be_kind_of( SpecHelper::Foo )
          @i.should == @obj.stateful
          @i.transitions.should_not be_empty
          @i.should_not be_halted
          @i.current_transition.should_not be_halted
          @i.transition!
          @i.current_transition.should be_halted
          @i.should be_halted
          @h = @i.current_transition.last_halt
          @i.state.name.should == :one
        end

        it "should have the message from the requirement in the last_halt" do
          mock( @obj ).ok?( @t ) { false }

          @i.transition!
          @i.should be_halted
          h = @i.current_transition.last_halt
          h.should be_kind_of( Stateful::TransitionHalted )
          h.transition.should == @i.current_transition
          h.source.should be_kind_of( Stateful::Event::Requirement )
          h.source.should == @i.current_transition.event.requirements.first
          h.message.should == "ok failed"
        end

        # todo - move this into another spec - the rules spec?
        it "should have the failing method name as a Symbol as the message if none is supplied and the condition was a symbol " do
          mock( @obj ).good?( @t ) { false }

          @i.transition!
          @i.should be_halted
          h = @i.current_transition.last_halt
          h.should be_kind_of( Stateful::TransitionHalted )
          h.transition.should == @i.current_transition
          h.source.should be_kind_of( Stateful::Event::Requirement )
          h.message.should == :good?
        end

        it "should know that it was halted from a requirement" do
          mock( @obj ).good?( @t ) { false }
          @i.transition!
          @i.should be_halted
          @i.halt.source.should be_kind_of( Stateful::Event::Requirement )
        end

        it "should know which requirement it was halted from" do
          mock( @obj ).good?( @t ) { false }

          @i.transition!
          @i.should be_halted
          @i.halt.source.should be_kind_of( Stateful::Event::Requirement )
          @i.halt.source.should == @event.requirements[:good?]
        end
      end

      it "should call executable? and return without running any hooks if it fails" do
        mock( @t ).executable?() { false }
        @i.transition!
        @i.state.name.should == :one
        @t.curr_hook.should be_nil
      end

      # TODO / should this be on the instance or whuh?
      it "should return an array of ALL failing requirements given t.event_requirement_failure_messages"

      it "should trigger all the event hooks on the correct objects"
      it "should trigger all hooks in the correct order"
    end

    describe "executable?" do
      describe "when the transition is halted during preconditions" do

      end
      describe "when no precondition failed " do
        it "should return true" do
          @t.executable?.should == true
        end

        it "should not halt the transition" do
          @t.executable?
          @t.should_not be_halted
        end
      end
    end

    describe "halt!" do
      it "should raise TransitionHalted with self & its args"
    end

    describe "halted_with" do
      it "should require a TransitionHalted" do
        lambda do
          @t.halted_with "camels"
        end.should raise_error( ArgumentError )

        lambda do
          @t.halted_with TransitionHalted.new( @t, "wellity", @t )
        end.should_not raise_error( )

      end
      it "should add it to exceptions" do
        h = TransitionHalted.new( @t, "wellity", @t )
        @t.exceptions.should be_empty
        @t.halted_with h
        @t.exceptions.should_not be_empty
        @t.exceptions.should == [h]
      end
    end

    describe "exceptions, halts" do
      it "should return the TransitionHalted exceptions added with halted_with" do
        h = TransitionHalted.new( @t, "wellity", @t )
        @t.exceptions.should be_empty
        @t.halted_with h
        @t.exceptions.should_not be_empty
        @t.exceptions.should == [h]
        @t.halts.should      == [h]
      end
    end

    describe "last_halt" do
      it "should return exceptions.last" do
        h = TransitionHalted.new( @t, "wellity", @t )
        @t.exceptions.should be_empty
        @t.halted_with h
        @t.exceptions.should_not be_empty
        @t.exceptions.should == [h]
        @t.last_halt.should == h
        h2 = TransitionHalted.new( @t, "wellity well", @t )
        @t.halted_with h2
        @t.last_halt.should == h2
      end
    end

    describe "halted?" do
      it "should be false if exceptions is empty, true if exceptions is not empty" do
        h = TransitionHalted.new( @t, "wellity", @t )
        @t.exceptions.should be_empty
        @t.should_not be_halted
        @t.halted_with h
        @t.exceptions.should_not be_empty
        @t.should be_halted
      end
    end

    describe "completed?" do
      it "should be true after a successful transition" do
        @i.transition!
        @i.state.name.should == :two
        @t.should_not be_halted
        @t.completed?.should == true
      end
    end

    describe "started?" do
      it "should be true if @started"
    end

    describe "active?" do
      it "should not be true if halted?"
      it "should not be true if complete?"
      it "should be true otherwise"
    end

    describe "impossible?" do
      it "should use Stateful to manage its own state without entering an infinite loop"
    end

    describe "resume" do
      it "would be easier after the above"
    end

    def reset!
      @halteds = []
      @args    = nil
    end

  end


  after do
    Stateful.reset!
  end

end
