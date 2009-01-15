require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

describe 'Stateful::Event' do
  include SpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  # so we can avoid fiddling around in each_state
  #it "should silently ignore any event pointing to itself "

  describe 'Constructor'

  describe "Class methods"

  describe "Instance methods"

end
