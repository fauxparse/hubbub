require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TaskListsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "task_lists", :action => "index").should == "/task_lists"
    end
  
    it "should map #new" do
      route_for(:controller => "task_lists", :action => "new").should == "/task_lists/new"
    end
  
    it "should map #show" do
      route_for(:controller => "task_lists", :action => "show", :id => 1).should == "/task_lists/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "task_lists", :action => "edit", :id => 1).should == "/task_lists/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "task_lists", :action => "update", :id => 1).should == "/task_lists/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "task_lists", :action => "destroy", :id => 1).should == "/task_lists/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/task_lists").should == {:controller => "task_lists", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/task_lists/new").should == {:controller => "task_lists", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/task_lists").should == {:controller => "task_lists", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/task_lists/1").should == {:controller => "task_lists", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/task_lists/1/edit").should == {:controller => "task_lists", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/task_lists/1").should == {:controller => "task_lists", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/task_lists/1").should == {:controller => "task_lists", :action => "destroy", :id => "1"}
    end
  end
end
