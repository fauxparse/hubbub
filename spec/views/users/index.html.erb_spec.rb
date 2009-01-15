require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/index.html.erb" do
  include UsersHelper
  
  before(:each) do
    assigns[:users] = [
      stub_model(User),
      stub_model(User)
    ]
  end

  # it "should render list of users" do
  #   render "/users/index.html.erb"
  # end
end

