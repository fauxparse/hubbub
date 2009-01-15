require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

describe 'Stateful' do
  include SpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe "class methods" do

    describe "Stateful[] accessor" do
      it "should just be a facade for Stateful::Specification[]"
    end

    describe "constructor given a Binding and an obj to be the receiver" do
      it "should return an Instance"
      it "should have access to the receiver and the Binding from the Instance"
    end

    describe "reset!" do
      it "should call Stateful::Specification.reset!"
    end

    describe "specifications" do
      it "should call Stateful::Specification.specifications"
    end

    describe "specify" do
      describe "with a block" do
        it ""
      end
      describe "without a block" do
        describe "with an existing specification name" do
          it "should return the Specification"
        end
        describe "without an existing specification name" do
          it "should return the Specification"
        end
      end
    end

  end
end
