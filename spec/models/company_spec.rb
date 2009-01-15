require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Company do
  before(:each) do
    @account = mock_model(Account)
    @valid_attributes = {
      :name => "Test Company",
      :account => @account
    }
  end

  it "should create a new instance given valid attributes" do
    Company.create!(@valid_attributes)
  end
end
