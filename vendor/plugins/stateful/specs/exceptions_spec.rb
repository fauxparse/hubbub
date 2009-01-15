require "#{File.dirname(__FILE__)}/spec_helper"
require "stateful"

describe 'Stateful::MissingStateField' do

  include SpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe "Constructor" do

  end
end

describe 'Stateful::IllegalTransition' do
  include SpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe "Constructor" do

  end
end

describe 'Stateful::IllegalEvent' do
  include SpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe "Constructor" do

  end
end

describe 'Stateful::IllegalState' do
  include SpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe "Constructor" do

  end
end


describe 'Stateful::TransitionHalted' do
  include SpecHelper

  before do
    Stateful.reset!
  end

  after do
    Stateful.reset!
  end

  describe "Constructor" do

  end
end
