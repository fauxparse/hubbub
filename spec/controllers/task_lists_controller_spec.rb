require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TaskListsController do

  # def mock_task_list(stubs={})
  #   @mock_task_list ||= mock_model(TaskList, stubs)
  # end
  # 
  # describe "responding to GET index" do
  # 
  #   it "should expose all task_lists as @task_lists" do
  #     TaskList.should_receive(:find).with(:all).and_return([mock_task_list])
  #     get :index
  #     assigns[:task_lists].should == [mock_task_list]
  #   end
  # 
  #   describe "with mime type of xml" do
  # 
  #     it "should render all task_lists as xml" do
  #       request.env["HTTP_ACCEPT"] = "application/xml"
  #       TaskList.should_receive(:find).with(:all).and_return(task_lists = mock("Array of TaskLists"))
  #       task_lists.should_receive(:to_xml).and_return("generated XML")
  #       get :index
  #       response.body.should == "generated XML"
  #     end
  #   
  #   end
  # 
  # end
  # 
  # describe "responding to GET show" do
  # 
  #   it "should expose the requested task_list as @task_list" do
  #     TaskList.should_receive(:find).with("37").and_return(mock_task_list)
  #     get :show, :id => "37"
  #     assigns[:task_list].should equal(mock_task_list)
  #   end
  #   
  #   describe "with mime type of xml" do
  # 
  #     it "should render the requested task_list as xml" do
  #       request.env["HTTP_ACCEPT"] = "application/xml"
  #       TaskList.should_receive(:find).with("37").and_return(mock_task_list)
  #       mock_task_list.should_receive(:to_xml).and_return("generated XML")
  #       get :show, :id => "37"
  #       response.body.should == "generated XML"
  #     end
  # 
  #   end
  #   
  # end
  # 
  # describe "responding to GET new" do
  # 
  #   it "should expose a new task_list as @task_list" do
  #     TaskList.should_receive(:new).and_return(mock_task_list)
  #     get :new
  #     assigns[:task_list].should equal(mock_task_list)
  #   end
  # 
  # end
  # 
  # describe "responding to GET edit" do
  # 
  #   it "should expose the requested task_list as @task_list" do
  #     TaskList.should_receive(:find).with("37").and_return(mock_task_list)
  #     get :edit, :id => "37"
  #     assigns[:task_list].should equal(mock_task_list)
  #   end
  # 
  # end
  # 
  # describe "responding to POST create" do
  # 
  #   describe "with valid params" do
  #     
  #     it "should expose a newly created task_list as @task_list" do
  #       TaskList.should_receive(:new).with({'these' => 'params'}).and_return(mock_task_list(:save => true))
  #       post :create, :task_list => {:these => 'params'}
  #       assigns(:task_list).should equal(mock_task_list)
  #     end
  # 
  #     it "should redirect to the created task_list" do
  #       TaskList.stub!(:new).and_return(mock_task_list(:save => true))
  #       post :create, :task_list => {}
  #       response.should redirect_to(task_list_url(mock_task_list))
  #     end
  #     
  #   end
  #   
  #   describe "with invalid params" do
  # 
  #     it "should expose a newly created but unsaved task_list as @task_list" do
  #       TaskList.stub!(:new).with({'these' => 'params'}).and_return(mock_task_list(:save => false))
  #       post :create, :task_list => {:these => 'params'}
  #       assigns(:task_list).should equal(mock_task_list)
  #     end
  # 
  #     it "should re-render the 'new' template" do
  #       TaskList.stub!(:new).and_return(mock_task_list(:save => false))
  #       post :create, :task_list => {}
  #       response.should render_template('new')
  #     end
  #     
  #   end
  #   
  # end
  # 
  # describe "responding to PUT udpate" do
  # 
  #   describe "with valid params" do
  # 
  #     it "should update the requested task_list" do
  #       TaskList.should_receive(:find).with("37").and_return(mock_task_list)
  #       mock_task_list.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => "37", :task_list => {:these => 'params'}
  #     end
  # 
  #     it "should expose the requested task_list as @task_list" do
  #       TaskList.stub!(:find).and_return(mock_task_list(:update_attributes => true))
  #       put :update, :id => "1"
  #       assigns(:task_list).should equal(mock_task_list)
  #     end
  # 
  #     it "should redirect to the task_list" do
  #       TaskList.stub!(:find).and_return(mock_task_list(:update_attributes => true))
  #       put :update, :id => "1"
  #       response.should redirect_to(task_list_url(mock_task_list))
  #     end
  # 
  #   end
  #   
  #   describe "with invalid params" do
  # 
  #     it "should update the requested task_list" do
  #       TaskList.should_receive(:find).with("37").and_return(mock_task_list)
  #       mock_task_list.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => "37", :task_list => {:these => 'params'}
  #     end
  # 
  #     it "should expose the task_list as @task_list" do
  #       TaskList.stub!(:find).and_return(mock_task_list(:update_attributes => false))
  #       put :update, :id => "1"
  #       assigns(:task_list).should equal(mock_task_list)
  #     end
  # 
  #     it "should re-render the 'edit' template" do
  #       TaskList.stub!(:find).and_return(mock_task_list(:update_attributes => false))
  #       put :update, :id => "1"
  #       response.should render_template('edit')
  #     end
  # 
  #   end
  # 
  # end
  # 
  # describe "responding to DELETE destroy" do
  # 
  #   it "should destroy the requested task_list" do
  #     TaskList.should_receive(:find).with("37").and_return(mock_task_list)
  #     mock_task_list.should_receive(:destroy)
  #     delete :destroy, :id => "37"
  #   end
  # 
  #   it "should redirect to the task_lists list" do
  #     TaskList.stub!(:find).and_return(mock_task_list(:destroy => true))
  #     delete :destroy, :id => "1"
  #     response.should redirect_to(task_lists_url)
  #   end
  # 
  # end
  # 
end
