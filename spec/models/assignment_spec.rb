require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Assignment do
  before(:each) do
    @task = mock_model Task
    @valid_attributes = {
      :task => @task
    }
  end

  it "should create a new instance given valid attributes" do
    Assignment.create!(@valid_attributes)
  end

  describe "created against a task" do
    before :each do
      @task = Task.create :name => "test task", :task_list_id => 1
      @user = users(:cookie)
      @time_slice = @task.time_slices.create :user => @user, :minutes => 45
      @assignment = @task.assignments.create :user => @user
    end
    
    it "should grab time slices recorded against the task when created" do
      @time_slice.reload.activity.should == @assignment
      @assignment.time_slices(:reload).should == [ @time_slice ]
      @task.time_slices(:reload).should be_empty
    end
    
    it "should give time slices to the task when destroyed" do
      @assignment.destroy
      @task.time_slices(:reload).should == [ @time_slice ]
    end
  end
end
