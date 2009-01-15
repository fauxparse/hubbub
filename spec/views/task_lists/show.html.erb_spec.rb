require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/task_lists/show.html.erb" do
  include TaskListsHelper
  
  before(:each) do
    assigns[:task_list] = @task_list = stub_model(TaskList)
  end

  # it "should render attributes in <p>" do
  #   render "/task_lists/show.html.erb"
  # end
end

