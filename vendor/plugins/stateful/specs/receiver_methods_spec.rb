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

  describe "module ModelClassMethods" do
    describe "stateful"
  end

end
