require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/companies/show.html.erb" do
  include CompaniesHelper
  
  before(:each) do
    assigns[:company] = @company = stub_model(Company)
  end

  # it "should render attributes in <p>" do
  #   render "/companies/show.html.erb"
  # end
end

