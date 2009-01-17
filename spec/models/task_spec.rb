require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Task do
  before(:each) do
    @task_list = mock_model TaskList
    @valid_attributes = {
      :name => "task",
      :task_list => @task_list
    }
  end

  it "should create a new instance given valid attributes" do
    Task.create!(@valid_attributes)
  end
end
