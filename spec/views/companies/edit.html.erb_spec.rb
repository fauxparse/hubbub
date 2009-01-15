require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/companies/edit.html.erb" do
  include CompaniesHelper
  
  before(:each) do
    assigns[:company] = @company = stub_model(Company,
      :new_record? => false
    )
  end

  # it "should render edit form" do
  #   render "/companies/edit.html.erb"
  #   
  #   response.should have_tag("form[action=#{company_path(@company)}][method=post]") do
  #   end
  # end
end


