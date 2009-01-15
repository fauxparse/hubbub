require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

describe 'Stateful::Binding' do
  include SpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe 'Constructor'

  describe "Class methods" do
    describe "[]" do
    end
  end

  describe "Instance methods" do
    describe "field_name"
    describe "bind!"
  end

  describe "helper methods" do
    describe "active_record?"
    describe "active_record_field?"
    describe "column_name"
  end

  describe "module ModelClassMethods" do
    describe "stateful"
  end

end
