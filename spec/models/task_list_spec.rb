require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TaskList do
  before(:each) do
    @account = mock_model(Account)
    @company = mock_model(Company, :account => @account)
    @project = mock_model(Project, :company => @company)
    @valid_attributes = {
      :name => "Test List",
      :project => @project
    }
  end

  it "should create a new instance given valid attributes" do
    TaskList.create!(@valid_attributes)
  end
  
  it "should start out with no open tasks" do
    TaskList.create(@valid_attributes).open_tasks_count.should be_zero
  end
  
  it "should start out empty" do
    TaskList.create(@valid_attributes).should be_empty
  end
end
