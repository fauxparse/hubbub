require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/task_lists/edit.html.erb" do
  include TaskListsHelper
  
  before(:each) do
    assigns[:task_list] = @task_list = stub_model(TaskList,
      :new_record? => false
    )
  end

  # it "should render edit form" do
  #   render "/task_lists/edit.html.erb"
  #   
  #   response.should have_tag("form[action=#{task_list_path(@task_list)}][method=post]") do
  #   end
  # end
end


