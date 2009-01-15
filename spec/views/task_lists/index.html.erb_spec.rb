require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/task_lists/index.html.erb" do
  include TaskListsHelper
  
  before(:each) do
    assigns[:task_lists] = [
      stub_model(TaskList),
      stub_model(TaskList)
    ]
  end

  it "should render list of task_lists" do
    render "/task_lists/index.html.erb"
  end
end

