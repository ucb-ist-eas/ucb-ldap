require File.expand_path("#{File.dirname(__FILE__)}/_setup")


describe UCB::LDAP::Namespace do
  before(:all) do
    namespace_bind()
  end

  before(:each) do
    @uid = '61065'
    @cn = 'runner'
  end

  after(:all) do
    UCB::LDAP.clear_authentication
  end
  
  it "should set tree base" do
    Namespace.tree_base.should == 'ou=names,ou=namespace,dc=berkeley,dc=edu'
  end
  
  it "should set entity name" do
    Namespace.entity_name.should == "namespaceName"
  end
  
  it "should set schema attributes" do
    Namespace.schema_attributes_array.should be_instance_of(Array)
    Namespace.schema_attributes_array[0].should be_instance_of(Schema::Attribute)
    lambda { Namespace.schema_attribute('berkeleyEduServices') }.should_not raise_error 
    lambda { Namespace.schema_attribute('bogus') }.should raise_error(BadAttributeNameException)
  end

  it "should find namespaces by uid and return Array of Namespace" do
    ns = Namespace.find_by_uid(@uid)
    ns.should be_instance_of(Array)
    ns.first.should be_instance_of(Namespace)
    ns.first.uid.should == @uid
  end
  
  it "should find namespaces by cn and return single Namespace" do
    ns = Namespace.find_by_cn(@cn)
    ns.class.should == Namespace
    ns.name.should == @cn
    ns.uid.should == @uid
  end
end


describe "UCB::LDAP::Namespace instance" do
  before(:all) do
    namespace_bind()
    @cn = 'runner'
    @n = Namespace.find_by_cn(@cn)
  end
  
  after(:all) do
    UCB::LDAP.clear_authentication
  end
  
  it "should return uid as scalar" do
    @n.uid.should == '61065'
  end

  it "should return name as scalar" do
    @n.name.should == @cn
  end
  
  it "should return services as an array" do
    @n.services.class.should == Array
    @n.services.should == ['calmail', "calnet", "webdisk"]
  end
end
