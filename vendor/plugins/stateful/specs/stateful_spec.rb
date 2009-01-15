## specs v2
## "the ones that make sense"
##
require "stateful"
require 'active_record'
require "#{File.dirname(__FILE__)}/models"

require "#{File.dirname(__FILE__)}/spec_helper"
require "#{File.dirname(__FILE__)}/old_spec_helper"

describe 'Stateful' do
  include SpecHelper
  include OldSpecHelper

  before do
    Stateful.reset!
    use_active_record
    @model = ModelWithStateful.new( )
  end

  after do
    Stateful.reset!
  end

  describe "included by an ActiveRecord class" do

    describe "with no specification block" do
      it "should have a stateful class method" do
        ModelWithStateful.should respond_to('stateful')
        lambda { ModelWithStateful.stateful }.should_not raise_error()
      end
    end

    describe "defining specifications" do

      before do
        ModelWithStateful.class_eval do

          stateful do
            state :default_state
          end

          stateful( :empty ) do
          end

          stateful( :nonempty ) do
            state :nonempty_state
          end

          stateful( :symbol_name ) do
            state :symbol_state
          end

          stateful( :last ) do
            state :last_state
          end
        end
      end

      after do
        Stateful.reset!
      end

      it "should return a current specification when Klass.stateful is called with no block" do

        default = Stateful[ ModelWithStateful, :stateful]
        default.should_not be_nil
        default.should be_kind_of( Stateful::Specification )
        default.states.map(&:name).should == [:default_state]
        ModelWithStateful.stateful.should_not be_nil
        ModelWithStateful.stateful.should == default
      end

      it "should create specifications for the class and bind them to accessor methods" do
        Stateful.specifications.should_not be_empty
        empty = Stateful[ ModelWithStateful, :empty ]
        empty.should_not be_nil
        empty.should be_kind_of( Stateful::Specification )
        empty.states.should == []

        nonempty = Stateful[ ModelWithStateful, :nonempty ]
        nonempty.should_not be_nil
        nonempty.should be_kind_of( Stateful::Specification )
        nonempty.states.map(&:name).should == [ :nonempty_state ]

        symbol = Stateful[ ModelWithStateful, :symbol_name ]
        symbol.should_not be_nil
        symbol.should be_kind_of( Stateful::Specification )
        symbol.states.map(&:name).should == [ :symbol_state ]

        last = Stateful[ ModelWithStateful, :last ]
        last.should_not be_nil
        last.should be_kind_of( Stateful::Specification )
        last.states.map(&:name).should == [ :last_state ]
      end

      it "should create an accessor on a non-ActiveRecord object when binding, if the state field is not accessible" do
        class Snoo
          include Stateful
          stateful do
            state :new do |state|
              state.event :go, :to => :next
            end
            state :next
          end
        end

        @snoo = Snoo.new

        @snoo.should respond_to('stateful')
        @snoo.stateful.should be_kind_of( Stateful::Instance )
        @snoo.stateful.specification.name.should == [ Snoo, :stateful ]
        @snoo.stateful.specification.should == Stateful[ Snoo, :stateful ]

        @snoo.should respond_to('go')
        @snoo.should respond_to('go?')

        @snoo.instance_variable_get( "@stateful_state" ).should_not be_nil
        @snoo.should respond_to( 'stateful_state' )
        @snoo.should respond_to( 'stateful_state=' )
        @snoo.stateful_state.should == 'new'
      end

      it "should raise an error when the instance is bound to an AR model if there is not a field for it" do
        Stateful.specify( :wombat ) do
          state :new
        end
        Stateful[ :wombat ].bind_to_class( Post, :wombat )
        @post = Post.new

        lambda do
          @post.wombat( )
        end.should raise_error( Stateful::MissingStateField )
      end

      it "should NOT raise an error when bound to an AR model if there is an instance variable accessor" do

        Stateful.specify( :wombat ) do
          state :new
        end
        Stateful[ :wombat ].bind_to_class( Post, :wombat )

        @post = Post.new

        Post.class_eval do
          attr_accessor :wombat_state
        end

        lambda do
          @post.wombat
        end.should_not raise_error( )

        @post.wombat
        @post.wombat_state.should == @post.wombat.state.name.to_s
        @post.wombat_state.should == "new"
      end

      describe "binding twice to different accessors " do
        before do
          Stateful.specify( :wombat ) do
            state :new do |state|
              state.event :go, :to => :next do |event|
              end
            end
            state :next do |state|
              state.event :go, :to => :last do |event|
              end
            end
            state :last
          end # specify

          Post.class_eval do
            attr_accessor :mammal_status
            attr_accessor :le_wombat
          end

          @post = Post.new # specs fail if this is before the attr_accessors
        end # before



        it "should bind to the instance method and field supplied with bind_to_class" do
          @mammal_binding = Stateful[:wombat].bind_to_class( Post,
                                                              :mammal,
                                                              "mammal_status" )
          @hairy_binding  = Stateful[:wombat].bind_to_class( Post,
                                                              :hairy_brick,
                                                              "le_wombat" )
          @hairy_binding.klass.should      == Post
          @hairy_binding.field_name.should == "le_wombat"
          @hairy_binding.accessor_name.should == :hairy_brick

          begin
            # @post.hairy_brick
          rescue NoMethodError

          end
          @post.should respond_to('hairy_brick')
          @post.should respond_to('mammal')

          lambda do
            @post.mammal
          end.should_not raise_error( )

          lambda do
            @post.hairy_brick
          end.should_not raise_error( )

          @post.mammal.should be_kind_of( Stateful::Instance )
          @post.mammal.specification.should be_kind_of( Stateful::Specification )
          @post.mammal.specification.should == Stateful[ :wombat ]

          @post.hairy_brick.should be_kind_of( Stateful::Instance )
          @post.hairy_brick.specification.should be_kind_of( Stateful::Specification )
          @post.hairy_brick.specification.should == Stateful[ :wombat ]
        end

        it "should be the state field" do
          Stateful[ :wombat ].bind_to_class( Post, :mammal,      "mammal_status" )
          Stateful[ :wombat ].bind_to_class( Post, :hairy_brick, "le_wombat" )
          @post = Post.new
          @post.mammal.field_name.should == 'mammal_status'
          @post.mammal_status.should_not be_nil
          @post.mammal_status.should == @post.mammal.state.name.to_s
          @post.mammal_status.should == "new"

          @post.hairy_brick.field_name.should == 'le_wombat'
          @post.le_wombat.should == @post.hairy_brick.state.name.to_s
          @post.le_wombat.should == "new"

          @post.mammal.send :set_state, :next

          @post.mammal.state.name.should == :next
          @post.mammal_status.should == "next"

          @post.hairy_brick.state.name.should == :new
          @post.le_wombat.should == "new"
        end

        it "should create an accessor if the field is not set"
      end # describe
    end
  end

  describe "creating a specification and later binding it to an ActiveRecord class" do

    before do
      @spec = Stateful.specify( :MySpecification ) do
        state :initial
      end
    end

    it "should bind to the specified class and accessor method" do
      Stateful[ :MySpecification ].should == @spec
      @spec.bind_to_class( ModelWithStateful, :my_accessor )
      lambda { @model.my_accessor }.should raise_error( Stateful::MissingStateField  )
      @model.class.class_eval do
        attr_accessor :my_accessor_state
      end
      lambda { @model.my_accessor }.should_not raise_error()
      @model.my_accessor.should be_kind_of( Stateful::Instance )
      @model.my_accessor.specification.should == @spec
    end

  end

  describe "An activerecord class with a simple specification" do

    before do
      setup_post_lifecycle()

      Stateful[ Post, :lifecycle ].bind_to_class( Post, :lifecycle )

      @post = Post.new()

      def it_should_match_with state_name, event_name, next_state_name

        #  puts "#{state_name} #{event_name} #{next_state_name}"

        states = @post.lifecycle.states
        states.should_not be_empty
        states.map(&:name).should include( state_name )
        states[ state_name ].should_not be_nil
        states[ state_name ].should be_kind_of( Stateful::State )
        states[ state_name ].events.should_not be_empty
        states[ state_name ].events.map(&:name).should include( event_name )
        evt = states[ state_name ].events[ event_name ]
        evt.should be_kind_of( Stateful::Event )
        evt.target_state_names.should be_kind_of( Array )
        evt.target_state_names.should_not be_empty
        evt.target_state_names.should include( next_state_name )

      end
    end

    it "should have a Stateful specification bound to the lifecycle method" do
      # setup_post_lifecycle
      @post.should respond_to('lifecycle')
      @post.lifecycle.should be_kind_of(Stateful::Instance)
      @post.lifecycle.receiver.should == @post

      Stateful[ Post, :lifecycle ].should be_kind_of(Stateful::Specification)
      Stateful[ Post, :lifecycle ].should == @post.lifecycle.specification

    end

    it "should have a series of basic states, with transitions to other states" do
      @post.lifecycle.states.map(&:name).should include(:first_draft)

      it_should_match_with :first_draft,    :revise,   :draft
      it_should_match_with :draft,          :review,   :reviewed_draft
      it_should_match_with :reviewed_draft, :finalize, :final_draft
      it_should_match_with :final_draft,    :publish,  :published
    end

    describe "attempting direct access to the state field" do
      it "won't stop you"
    end

    describe "post-specify verification" do

      it "should verify that all events point to states that have been defined, after specification is complete" do
        lambda do
          Stateful.specify :broken do
            state :snoo do |s|
              s.event :wee, :to => :old_sydney_town
            end
            state :snuh
          end
        end.should raise_error( Stateful::IllegalState )
      end
    end

    it "should have defined an execute hook for :revise" do
      e = @post.lifecycle.states[ :first_draft ].events[:revise]
      e.hooks.execute.should be_kind_of( Proc )
    end

    it "should redefine an existing execute hook for :revise" do
      e = @post.lifecycle.states[ :first_draft ].events[:revise]
      e.execute :scribble_in_margins
      e.hooks.execute.should be_kind_of( Symbol )
    end


    it "should have an all_events method returning a name sorted list of all events" do
      all_events = @post.lifecycle.states.map(&:events).flatten.uniq.sort_by { |o| o.name.to_s }
      @post.lifecycle.specification.should respond_to("all_events")
      @post.lifecycle.specification.all_events.should == all_events
      @post.lifecycle.all_events.should == all_events
    end

    describe "the :publish event declaration with requirements " do
      it "should have a requirement whose condition is :approved_by_supervisor?" do
        evt = @post.lifecycle.states[:final_draft].events[:publish]
        evt.requirements.should_not be_empty
        req = evt.requirements.detect { |r| r.condition == :approved_by_supervisor? }
        req.should_not be_nil
        req.should be_kind_of( Stateful::Event::Requirement )
      end
    end

    describe "When the state field is an ActiveRecord column " do

      it "should be the first state if the state column is nil" do
        @post.read_attribute('lifecycle_state').should be_nil
        @post.lifecycle.column_name.should == 'lifecycle_state'
        @post.read_attribute('lifecycle_state').should == @post.lifecycle.state.name.to_s
        @post.class.columns.map(&:name).should include( "lifecycle_state" )
        @post.lifecycle.state.should == @post.lifecycle.states.first
        @post.lifecycle.state.name.should == :first_draft
      end

      it "should be the named state if the state column is not nil" do
        @post.write_attribute('lifecycle_state', 'final_draft')
        @post.read_attribute('lifecycle_state').should == 'final_draft'
        @post.lifecycle.state.name.should == :final_draft
        @post.lifecycle.state.should == @post.lifecycle.states[:final_draft]
        @post.lifecycle.state.name.should == :final_draft
      end

      it "should set initial state when the state accessor is first called" do
        @post.lifecycle.state.should_not be_nil
        @post.write_attribute('lifecycle_state', 'final_draft')
        @post.lifecycle.state.name.should    == :first_draft
      end

      it "should set its initial state again when reload_state! is called" do
        @post.lifecycle.state.should_not be_nil
        @post.write_attribute('lifecycle_state', 'final_draft')
        @post.lifecycle.state_field_value.should == 'final_draft'
        @post.lifecycle.state.name.should     == :first_draft
        @post.lifecycle.reload_state!.should  == :final_draft # do reload
        @post.lifecycle.state.name.should     == :final_draft
      end

      it "should raise IllegalState when a bad state is in the state field" do
        @post.lifecycle.state.name.should    == :first_draft
        @post.write_attribute('lifecycle_state', 'crappotron')
        lambda { @post.lifecycle.reload_state! }.should raise_error( Stateful::IllegalState )
      end

      it "should reconstitute an object with the state in the state column" do
        p2 = Post.new( { :lifecycle_state => "final_draft" })
        p2.lifecycle.state.name.should == :final_draft
      end
    end

    describe "When the state field is an instance variable accessor" do
      before do
        Post.class_eval do
          attr_accessor :wibble_state
        end
        Stateful::Binding[ Post, :lifecycle].field_name = :wibble_state
      end

      it "should reconstitute the current state from the state field" do
        @post.lifecycle.field_name.should     == 'wibble_state'
        @post.lifecycle.state.name.should     == :first_draft
        @post.wibble_state                     = :final_draft
        @post.lifecycle.reload_state!.should  == :final_draft
        @post.lifecycle.state.name.should     == :final_draft
      end

    end

    describe "A specification with two states and all event hooks changing state" do

      before do
        setup_event_tester
        Stateful[ EventTester, :stateful ].bind_to_class( EventTester, :stateful )
        @tester = EventTester.new()
      end

      it "should have an initial state of :new" do
        @tester.stateful.state.name.should == :new
      end

      it "should have event hooks for [before, execute, after] :change " do
        hooks = @tester.stateful.states[:new].events[:change].hooks
        [:before, :execute, :after].each do |hook|
          hooks.send(hook).should_not be_nil
          hooks.send(hook).should be_kind_of( Proc )
        end
      end

      describe "checking whether an event can be executed" do
        it "should yield a Transition object to all requirement condition blocks"
        it "should yield a Transition object to all satisfier blocks"
      end

      describe "triggering an event" do

        it "should change the bound instance's internal state " do
          @tester.should respond_to('change')
          @tester.change(  )
          @tester.stateful.state_name.should == :old
        end


        it "should yield a Transition object to all event hooks defined in the specification"

        it "should trigger all hooks in the correct sequence" do
          @tester.should respond_to('change')
          @tester.change(  )
          @tester.stateful.state_name.should == :old
          @tester.messages.should == [:before_before,
                                      :before,
                                      :on_exit,
                                      :after_on_exit,
                                      :on_entry,
                                      :after_on_entry,
                                      :before_execute,
                                      :execute,
                                      :before_after,
                                      :after]
        end

        describe "aborting the transition if halt is called" do
          it "should not change the state if halt is called" do
            initial_state = :new
            @tester.stateful.state_name.should == initial_state
            @tester.stateful.states[:new].hooks.remove :exit
            @tester.stateful.states[:new].hooks.on_exit.should be_nil
            @tester.stateful.states[:new].on_exit do |t|
              t.halt!( "snoo" )
             end
            @tester.stateful.states[:new].hooks.on_exit.should_not be_nil
            @tester.stateful.state.name.should == :new
            @tester.change()
            @tester.stateful.transitions.should_not be_nil
            @tester.stateful.transitions.should_not be_empty
            @tester.stateful.transitions.last.should be_kind_of( Stateful::Transition )

            # @tester.stateful.transitions.last.last_halt.should_not be_nil
            @tester.stateful.transitions.last.should be_halted

            @tester.stateful.current_transition.should_not be_nil
            @tester.stateful.current_transition.should == @tester.stateful.transitions.last
            @tester.stateful.current_transition.should_not be_complete
            @tester.stateful.current_transition.should be_halted
            @tester.stateful.halted?.should == true
            halt = @tester.stateful.current_transition.last_halt
            halt.should be_kind_of( Stateful::TransitionHalted )
            halt.transition.should be_kind_of( Stateful::Transition )
            halt.transition.should == @tester.stateful.current_transition
            halt.message.should == "snoo"
            halt.to_s.should =~ /snoo/
            @tester.stateful.state.name.should == initial_state
          end
        end

        describe "updating an activerecord field before saving" do
          it "should set the default state when the instance is referenced" do
            @tester.stateful_state.should be_nil
            @tester.stateful
            @tester.stateful_state.should_not be_nil
            @tester.stateful_state.should == "new"
            lambda { @tester.save! }.should_not raise_error()
            @tester.reload
            @tester.stateful_state.should == "new"
          end

          it "should should update the state field on transition" do

            @tester.stateful.states[:new].on_exit do |model|
              # don't halt!
            end
            @tester.stateful.state.name.should == :new
            @tester.stateful.state.events.map(&:name).should include(:change)
            @tester.stateful.state.events[:change].should be_single_target
            @tester.stateful.state.events[:change].target_state.name.should == :old

            @tester.should respond_to('change')
            @tester.change( )
            @tester.stateful.halted?.should == false
            @tester.stateful.state.name.should == :old
            @tester.stateful_state.should == "old"
            lambda { @tester.save! }.should_not raise_error()
            @tester.reload
            @tester.stateful.state.name.should == :old
          end

        end

      end
    end

    describe "requirements, conditions and satisfy" do

      before do
        Stateful.specify( :requirements_test ) do
          state :new do |state|
            state.event :change, :to => :next do |event|

              event.requires( :valid?,
                              :message => lambda { |o| o.errors.to_a.inspect })

              event.requires( :has_permission,
                              :message => "You have to have permission") do |model, *args|
                model.has_permissions?( *args )
              end

              event.satisfy( :except => :valid? ) do
              end
            end
          end

          state :next

          every_event do |event|
            event.requires( :truth,
                            :message => "If this isn't true, you've got problems") do
              true
            end

          end
        end
        @spec = Stateful[ :requirements_test ]
        @spec.should be_kind_of( Stateful::Specification )
      end

      it "should have a ? method for each event which is true if the event conditions have been satisfied"

      describe "requirements" do

        it "must have a symbol as its first argument" do
          lambda do
            @spec.states[:new].events.first.requires( "snoo" ){  true }
          end.should raise_error( ArgumentError )
          lambda do
            @spec.states[:new].events.first.requires( :snoo ){  true }
          end.should_not raise_error( ArgumentError )
        end

        it "should have the name provided as the first argument" do
          @spec.states[:new].events[:change].requirements.should_not be_empty
          req_names = @spec.states[:new].events[:change].requirements.map(&:name)
          req_names.should == req_names.compact
          req_names.all? { |n| n.class == Symbol }
          req_names.should include(:valid?)
          req_names.should include(:has_permission)
          req_names.should include(:truth)
          req_names.should_not include(:snoo)
        end

        describe "bound to a receiver and evaluating conditions" do
          before do
            @binding = Stateful[ :requirements_test ].bind_to_class( Post, :reqs )
            Post.class_eval do
              attr_accessor :reqs_state
            end
            @post = Post.new
            @post.reqs
            @post.reqs.should be_kind_of( Stateful::Instance )
            @post.reqs.specification.should be_kind_of( Stateful::Specification )
            @post.reqs.specification.should == @spec
            @post.reqs.state.name.should == :new
            @post.reqs_state.should == @post.reqs.state.name.to_s
          end

          it "will call the method by its name on the reciever if it is not defined with a block" do

          end

          it "will call the block, passing the receiver and any arguments, if it is defined with a block"

        end
      end # requirements

      describe "satisfiers" do
        describe "matching requirements with :only / :except options" do
          it "will satisfy any requirements matching the options supplied (by requirement name)"

        end
      end # satisfiers

    end
  end
end

