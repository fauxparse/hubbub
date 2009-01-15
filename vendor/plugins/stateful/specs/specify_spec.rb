require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

describe 'Stateful.specify' do
  include SpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe "An empty specification" do

    describe "With no arguments" do

      before do
        @spec = Stateful.specify do
          # nothing to see here
        end
      end

      it "should create a new Specification" do
        @spec.should be_kind_of( Stateful::Specification )
      end

      it "should have a name of [ Specification, :default ]" do
        @spec.name.should == [ Stateful::Specification, :default ]
      end

      it "should be accessible through Stateful[] by name" do
        @spec.should == Stateful[ Stateful::Specification, :default ]
      end

      it "should be accessible through Stateful[] with the same args as specify" do
        @spec.should == Stateful[ ]
      end

      it "should have an empty states collection" do
        @spec.states.should == []
      end

      it "should have no events" do
        @spec.all_events.should == []
      end

    end

    describe "With a single argument which is a symbol (:my_specification)" do

      before do
        @spec = Stateful.specify( :my_specification ) do
          # nothing to see here
        end
      end

      it "should create a new Specification" do
        @spec.should be_kind_of( Stateful::Specification )
      end

      it "should have a name of [ Specification, :my_specification ]" do
        @spec.name.should == [ Stateful::Specification, :my_specification ]
      end

      it "should be accessible through Stateful[] by name" do
        @spec.should == Stateful[ Stateful::Specification, :my_specification ]
      end

      it "should be accessible through Stateful[] with the same args as specify" do
        @spec.should == Stateful[ :my_specification ]
      end

      it "should have an empty states collection" do
        @spec.states.should == []
      end

      it "should have no events" do
        @spec.all_events.should == []
      end

    end

    describe "With a single argument which is a class (String)" do

      before do
        @spec = Stateful.specify( String ) do
          # nothing to see here
        end
      end

      it "should create a new Specification" do
        @spec.should be_kind_of( Stateful::Specification )
      end

      it "should have a name of [ String, :default ]" do
        @spec.name.should == [ String, :default ]
      end

      it "should be accessible through Stateful[] by name" do
        @spec.should == Stateful[ String, :default ]
      end

      it "should be accessible through Stateful[] with the same args as specify" do
        @spec.should == Stateful[ String ]
      end

      it "should have an empty states collection" do
        @spec.states.should == []
      end

      it "should have no events" do
        @spec.all_events.should == []
      end

    end

    describe "With two arguments (String, :my_specification)" do

      before do
        @spec = Stateful.specify( String, :my_specification ) do
          # nothing to see here
        end
      end

      it "should create a new Specification" do
        @spec.should be_kind_of( Stateful::Specification )
      end

      it "should have a name of [ String, :my_specification ]" do
        @spec.name.should == [ String, :my_specification ]
      end

      it "should be accessible through Stateful[] by name" do
        @spec.should == Stateful[ String, :my_specification ]
      end

      it "should have an empty states collection" do
        @spec.states.should == []
      end

      it "should have no events" do
        @spec.all_events.should == []
      end
    end
  end # empty specification

  describe "Defining the default specification" do

    describe "with two states only" do

      before do
        Stateful.specify do
          state :first
          state :last
        end
        @spec = Stateful[ :default ]
      end

      it "Should have two States in the order they were defined" do
        @spec.states.length.should == 2
        @spec.states.first.name.should == :first
        @spec.states.last.name.should  == :last
        @spec.states.all? { |e| e.should be_kind_of( Stateful::State ) }
      end

      it "Should have no Events" do
        @spec.states.first.events.should be_empty
        @spec.states.last.events.should be_empty
        @spec.all_events.should be_empty
      end

    end

    describe "with two states and one event" do

      before do
        Stateful.specify do
          state :first do |s|
            s.event :go, :to => :last
          end
          state :last
        end
        @spec = Stateful[ :default ]
      end

      it "Should have a single event which transitions to :last" do
        @spec.states.first.events.should_not be_empty
        @spec.states.first.events.length.should == 1
        e = @spec.states.first.events.first
        e.should be_kind_of( Stateful::Event )
        e.name.should == :go
        e.target_state_name.should  == :last
        e.target_state_names.should == [:last]
        e.single_target?.should be_true
        e.initial_state.name.should == :first
      end

      it "Should know which events transition to :last" do
        e = @spec.states.first.events.first
        last = @spec.states.last
        last.should respond_to('events_to')
        last.events_to.should == [e]
      end

    end

    describe "with two states and one event with conditions" do

      before do
        Stateful.specify do
          state :first do |s|
            s.event :go, :to => :last do |e|
              e.requires :valid?, :message => "Sorry, not valid"
              e.requires :my_rule do |t|
                true
              end

              e.satisfy :all do
                false
              end

            end
          end
          state :last
        end
        @spec = Stateful[ :default ]
      end

      it "Should have a single event which transitions to :last" do
        @spec.states.first.events.should_not be_empty
        @spec.states.first.events.length.should == 1
        e = @spec.states.first.events.first
        e.should be_kind_of( Stateful::Event )
        e.name.should == :go
        e.target_state_name.should  == :last
        e.target_state_names.should == [:last]
        e.single_target?.should be_true
        e.initial_state.name.should == :first
      end

      it "Should know which events transition to :last" do
        e = @spec.states.first.events.first
        last = @spec.states.last
        last.should respond_to('events_to')
        last.events_to.should == [e]
      end

      describe "being redefined" do
        before do
          @spec = Stateful.specify do
            state :other
            state :first do |s|
              s.event :go_other, :to => :other
            end
          end
        end

        it "should still have the state :last" do
          @spec.states[:last].should be_kind_of( Stateful::State )
        end

        it "should still have the event :go from :first to :last" do
          @spec.states[:first].events[:go].should be_kind_of( Stateful::Event )
        end

        it "should now have a state :other" do
          @spec.states[:other].should be_kind_of( Stateful::State )
        end

        it "should now have an event :go_other from :first to :other" do
          @spec.states[:first].events[:go_other].should_not be_nil
          @spec.states[:first].events[:go_other].should be_kind_of( Stateful::Event )
          @spec.states[:first].events[:go_other].target_state_names.should == [:other]
        end
      end
    end

    describe "defining a specification with metainformation" do
      before do
        @spec = Stateful.specify( :meta => { :whatami => Stateful }) do
          state :one, :meta => { :number => 1 } do |s|
            s.event( :twoify,
                     :to => :two,
                     :meta => {
                       :real_word => false
                     }) do |e|
              e.requires :some_condition, :meta => { :condition => :some }

              e.satisfy :all, :meta => { :relevant => false } do
                false
              end

            end
          end

          state :two, :meta => { :number => 2 }
        end
      end

      it "should add metainformation to the Specification" do
        @spec.meta.should == { :whatami => Stateful }
      end

      it "should add metainformation to the State" do
        @spec.states[:one].meta.should == { :number => 1 }
      end

      it "should add metainformation to the Event" do
        @spec.states[:one].events.first.meta.should == { :real_word => false }
      end

      it "should add metainformation to the Requirement" do
        @spec.states[:one].events.first.requirements.first.meta.should == { :condition => :some }
      end

      it "should add metainformation to the Satisfier" do
        @spec.states[:one].events.first.satisfiers.first.meta.should == { :relevant => false }
      end

      it "should add metainformation to the Halter"

      # elsewhere
      it "should add metainformation to the Transition"
      it "should add metainformation to the Instance"
      it "should add metainformation to the Binding"

    end

  end # the default specification

end
