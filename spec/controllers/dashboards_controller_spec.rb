require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DashboardsController do
  before :each do
    controller.stub!(:current_account).and_return(accounts(:test))
  end
  
  describe "when logged in" do
    before :each do
      login(:cookie)
    end

    it "should show the dashboard" do
      get :show
      response.should render_template("show")
    end
  end

  describe "when not logged in" do
    it "should require login" do
      get :show
      response.should redirect_to("login")
    end
  end
end
