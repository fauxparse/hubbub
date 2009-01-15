require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

describe 'Stateful::State' do
  include SpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe "Class methods:" do
  end

  describe "Constructor method" do
    it "should require a Specification for the first arg"
    it "should require a Symbol name for the 2nd arg"
    it "should allow a hash of options as the 3rd arg"

  end

  describe "Instance methods:" do
    describe "event" do
      describe "when an Event of the given name doesn't exist" do
        it "should create a new event"

        # so we can avoid fiddling around in each_state
        it "should silently ignore any event pointing to itself "

        it "should yield the event to the block if given"
        it "should add the event to the State's events"
      end
    end

    describe "events_to" do
      it "should return any events in the specification that can transition to the State"
    end
  end

  describe "Stateful::Events::StateMethods" do
    describe "hooks" do
    end

    describe "on_entry" do
    end

    describe "on_exit" do
    end

  end
end
