require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TimeSlice do
  before(:each) do
    @task = Task.create :name => "task", :billable => true, :task_list_id => 1
    @user = users(:cookie)
    @assignment = Assignment.create :user => @user, :task => @task
    
    @assignment.total_minutes.should be_zero
  end

  it "should create successfully with valid attributes" do
    TimeSlice.create! :activity => @assignment, :user => @user
  end
  
  it "should create successfully with hours instead of minutes" do
    @time_slice = TimeSlice.create! :activity => @assignment, :user => @user, :hours => "1:45"
    @time_slice.minutes.should == 105
    @assignment.reload.total_minutes.should == 105
  end
  
  [ true, false ].each do |billable|
    describe "(#{"not " unless billable}billable; " do
      describe "first on a new assignment)" do
        before :each do
          @time_slice = @assignment.time_slices.create :user => @user, :minutes => 35, :billable => billable
        end
      
        it "should add to the total minutes #{billable ? "and" : "but not"} the billable minutes" do
          @assignment.reload
          @assignment.total_minutes.should == 35
          @assignment.billable_minutes.should == (billable ? 35 : 0)
        end
      
        it "should update the total minutes #{billable ? "and" : "but not"} the billable minutes" do
          @time_slice.update_attribute :minutes, 55
          @assignment.reload
          @assignment.total_minutes.should == 55
          @assignment.billable_minutes.should == (billable ? 55 : 0)
        end
        
        it "should update billable minutes when billable is switched" do
          @time_slice.update_attribute :billable, !billable
          @assignment.reload
          @assignment.total_minutes.should == 35
          @assignment.billable_minutes.should == (billable ? 0 : 35)
        end
      
        it "should update both counters when time is changed and billable is switched" do
          @time_slice.update_attributes :minutes => 55, :billable => !billable
          @assignment.reload
          @assignment.total_minutes.should == 55
          @assignment.billable_minutes.should == (billable ? 0 : 55)
        end
      
        it "should clear out the time when deleted" do
          @time_slice.destroy
          @assignment.reload
          @assignment.total_minutes.should == 0
          @assignment.billable_minutes.should == 0
        end
      end

      describe "nth on an assignment)" do
        before :each do
          @assignment.time_slices.create :user => @user, :minutes => 150, :billable => true
          @assignment.time_slices.create :user => @user, :minutes => 10, :billable => false
          @assignment.reload.billable_minutes.should == 150
          @assignment.total_minutes.should == 160
          @time_slice = @assignment.time_slices.create :user => @user, :minutes => 35, :billable => billable
        end
      
        it "should add to the total minutes #{billable ? "and" : "but not"} the billable minutes" do
          @assignment.reload
          @assignment.total_minutes.should == 195
          @assignment.billable_minutes.should == (billable ? 185 : 150)
        end
      
        it "should update the total minutes #{billable ? "and" : "but not"} the billable minutes" do
          @time_slice.update_attribute :minutes, 55
          @assignment.reload
          @assignment.total_minutes.should == 215
          @assignment.billable_minutes.should == (billable ? 205 : 150)
        end
      
        it "should update billable minutes when billable is switched" do
          @time_slice.update_attribute :billable, !billable
          @assignment.reload
          @assignment.total_minutes.should == 195
          @assignment.billable_minutes.should == (billable ? 150 : 185)
        end
      
        it "should update both counters when time is changed and billable is switched" do
          @time_slice.update_attributes :minutes => 55, :billable => !billable
          @assignment.reload
          @assignment.total_minutes.should == 215
          @assignment.billable_minutes.should == (billable ? 150 : 205)
        end
      
        it "should clear out the time when deleted" do
          @time_slice.destroy
          @assignment.reload
          @assignment.billable_minutes.should == 150
          @assignment.total_minutes.should == 160
        end
      end
    end
  end
end
