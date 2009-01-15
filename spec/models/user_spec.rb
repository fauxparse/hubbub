require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @account = mock_model(Account)
    @valid_attributes = {
      :name  => "Mr Test",
      :email => "test@example.com",
      :login => "test",
      :password => "test",
      :password_confirmation => "test"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end
  
  it "should require a name" do
    create_user(:name => nil).should_not be_valid
  end
  
  it "should require a login" do
    create_user(:login => nil).should_not be_valid
  end
  
  it "should require a password" do
    create_user(:password => nil).should_not be_valid
  end
    
  it "should require confirmation of password" do
    create_user(:password_confirmation => nil).should_not be_valid
  end
  
  it "should require passwords to match" do
    create_user(:password_confirmation => "wrong").should_not be_valid
  end
    
  it "should require an email address" do
    create_user(:email => nil).should_not be_valid
  end
  
  def create_user(params = {})
    User.create params.reverse_merge(@valid_attributes)
  end
end
