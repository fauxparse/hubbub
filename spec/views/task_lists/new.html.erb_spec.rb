require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/task_lists/new.html.erb" do
  include TaskListsHelper
  
  before(:each) do
    assigns[:task_list] = stub_model(TaskList,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/task_lists/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", task_lists_path) do
    end
  end
end


