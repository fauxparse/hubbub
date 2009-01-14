require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CompaniesController do

  def mock_company(stubs={})
    @mock_company ||= mock_model(Company, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all companies as @companies" do
      Company.should_receive(:find).with(:all).and_return([mock_company])
      get :index
      assigns[:companies].should == [mock_company]
    end

    describe "with mime type of xml" do
  
      it "should render all companies as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Company.should_receive(:find).with(:all).and_return(companies = mock("Array of Companies"))
        companies.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested company as @company" do
      Company.should_receive(:find).with("37").and_return(mock_company)
      get :show, :id => "37"
      assigns[:company].should equal(mock_company)
    end
    
    describe "with mime type of xml" do

      it "should render the requested company as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Company.should_receive(:find).with("37").and_return(mock_company)
        mock_company.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new company as @company" do
      Company.should_receive(:new).and_return(mock_company)
      get :new
      assigns[:company].should equal(mock_company)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested company as @company" do
      Company.should_receive(:find).with("37").and_return(mock_company)
      get :edit, :id => "37"
      assigns[:company].should equal(mock_company)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created company as @company" do
        Company.should_receive(:new).with({'these' => 'params'}).and_return(mock_company(:save => true))
        post :create, :company => {:these => 'params'}
        assigns(:company).should equal(mock_company)
      end

      it "should redirect to the created company" do
        Company.stub!(:new).and_return(mock_company(:save => true))
        post :create, :company => {}
        response.should redirect_to(company_url(mock_company))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved company as @company" do
        Company.stub!(:new).with({'these' => 'params'}).and_return(mock_company(:save => false))
        post :create, :company => {:these => 'params'}
        assigns(:company).should equal(mock_company)
      end

      it "should re-render the 'new' template" do
        Company.stub!(:new).and_return(mock_company(:save => false))
        post :create, :company => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested company" do
        Company.should_receive(:find).with("37").and_return(mock_company)
        mock_company.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :company => {:these => 'params'}
      end

      it "should expose the requested company as @company" do
        Company.stub!(:find).and_return(mock_company(:update_attributes => true))
        put :update, :id => "1"
        assigns(:company).should equal(mock_company)
      end

      it "should redirect to the company" do
        Company.stub!(:find).and_return(mock_company(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(company_url(mock_company))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested company" do
        Company.should_receive(:find).with("37").and_return(mock_company)
        mock_company.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :company => {:these => 'params'}
      end

      it "should expose the company as @company" do
        Company.stub!(:find).and_return(mock_company(:update_attributes => false))
        put :update, :id => "1"
        assigns(:company).should equal(mock_company)
      end

      it "should re-render the 'edit' template" do
        Company.stub!(:find).and_return(mock_company(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested company" do
      Company.should_receive(:find).with("37").and_return(mock_company)
      mock_company.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the companies list" do
      Company.stub!(:find).and_return(mock_company(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(companies_url)
    end

  end

end
