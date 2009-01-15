require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

describe 'Stateful::EveryEvent' do
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
  end

  describe "Instance methods:" do
  end
end
