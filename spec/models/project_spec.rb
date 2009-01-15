require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  before(:each) do
    @account = mock_model(Account)
    @company = mock_model(Company, :account => @account)
    @valid_attributes = {
      :name => "Test Project",
      :company => @company
    }
  end

  it "should create a new instance given valid attributes" do
    Project.create!(@valid_attributes)
  end
end
