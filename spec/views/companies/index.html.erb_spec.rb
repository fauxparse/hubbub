require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/companies/index.html.erb" do
  include CompaniesHelper
  
  before(:each) do
    assigns[:companies] = [
      stub_model(Company),
      stub_model(Company)
    ]
  end

  it "should render list of companies" do
    render "/companies/index.html.erb"
  end
end

