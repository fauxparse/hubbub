require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/show.html.erb" do
  include UsersHelper
  
  before(:each) do
    assigns[:user] = @user = stub_model(User)
  end

  # it "should render attributes in <p>" do
  #   render "/users/show.html.erb"
  # end
end

