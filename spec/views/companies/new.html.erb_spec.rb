require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/companies/new.html.erb" do
  include CompaniesHelper
  
  before(:each) do
    assigns[:company] = stub_model(Company,
      :new_record? => true
    )
  end

  # it "should render new form" do
  #   render "/companies/new.html.erb"
  #   
  #   response.should have_tag("form[action=?][method=post]", companies_path) do
  #   end
  # end
end


