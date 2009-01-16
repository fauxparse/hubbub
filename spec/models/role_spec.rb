require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  before(:each) do
    @valid_attributes = {
      :name => :role
    }
  end

  it "should create a new instance given valid attributes" do
    create_role.should be_valid
  end
  
  it "should normalise the name attribute" do
    create_role(:name => "Role Name").name.should == "role_name"
  end
  
  it "should convert to a symbol" do
    create_role.to_sym.should == :role
  end

  def create_role(params = {})
    Role.create @valid_attributes.merge(params)
  end
end
