require "stateful"
require 'active_record'
require "#{File.dirname(__FILE__)}/spec_helper"
require "#{File.dirname(__FILE__)}/old_spec_helper"
require "#{File.dirname(__FILE__)}/models"

class Foo < ActiveRecord::Base
  include Stateful
  set_table_name "spec_models"
end

include SpecHelper
include OldSpecHelper
describe "wtf" do
  it "snoo?" do
    use_active_record
    setup_post_lifecycle
    Stateful.specify Posty, :life do

      state :wuzza
    end
  end
end
