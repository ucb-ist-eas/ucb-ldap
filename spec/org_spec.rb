require File.expand_path("#{File.dirname(__FILE__)}/_setup")


describe UCB::LDAP::Org do
  before(:all) do
    # when fetching > 200 entries, we need to point to production
    UCB::LDAP.host = UCB::LDAP::HOST_PRODUCTION
  end

  after(:all) do
    # revert to test host in case suite of specs are being run
     UCB::LDAP.host = HOST_TEST
  end
  
  it "should set tree base" do
    UCB::LDAP::Org.tree_base.should == 'ou=org units,dc=berkeley,dc=edu'
  end
  
  it "should set entity name" do
    UCB::LDAP::Org.entity_name.should == "org"
  end
  
  it "should set schema attributes" do
    UCB::LDAP::Org.schema_attributes_array.should be_instance_of(Array)
    UCB::LDAP::Org.schema_attributes_array[0].should be_instance_of(UCB::LDAP::Schema::Attribute)
    ou_attr = UCB::LDAP::Org.schema_attribute(:ou)
  end

  it "find_by_ou should fetch Org instance" do
    UCB::LDAP::Org.clear_all_nodes
    e = UCB::LDAP::Org.find_by_ou('jkasd')
    e.should be_instance_of(UCB::LDAP::Org)
    e.ou.should == ['JKASD']
    # verify cache empty
    UCB::LDAP::Org.all_nodes_i.should be_nil
  end
  
  it 'org_by_ou is alias for find_by_ou' do
    e = UCB::LDAP::Org.org_by_ou('jkasd')
    e.should be_instance_of(UCB::LDAP::Org)
  end

  it 'search should return Array of UCB::LDAP::Org' do
    entries = UCB::LDAP::Org.search(:filter => {:ou => 'jkasd'})
    entries.should be_instance_of(Array)
    entries[0].should be_instance_of(UCB::LDAP::Org)
  end

  it 'root_node should return the root node' do
    UCB::LDAP::Org.root_node.deptid.should == 'UCBKL'
  end

  it "should load_all_nodes" do
    UCB::LDAP::Org.clear_all_nodes
    UCB::LDAP::Org.all_nodes_i.should be_nil
    UCB::LDAP::Org.load_all_nodes
    UCB::LDAP::Org.all_nodes_i.should have_at_least(1000).keys
  end
  
  it "should return Array of all org nodes when sent all_nodes()" do
    all_nodes = UCB::LDAP::Org.all_nodes
    all_nodes.should have_at_least(1000).keys
    all_nodes[all_nodes.keys.first].should be_instance_of(UCB::LDAP::Org)
  end

  it "should cache the org tree" do
    UCB::LDAP::Org.clear_all_nodes
    UCB::LDAP::Org.all_nodes_i.should be_nil
    UCB::LDAP::Org.all_nodes
    UCB::LDAP::Org.all_nodes_i.should_not be_nil
    # In the future, additional nodes may be added or deleted directly beneath
    # the root node, in which case this test would fail need to be altered.
    # Such a change has not happend since 2002.
    UCB::LDAP::Org.root_node.child_nodes_i.should have(13).keys
  end

  it "should be able to fetch orgs from cache" do
    UCB::LDAP::Org.clear_all_nodes
    UCB::LDAP::Org.find_by_ou_from_cache("jkasd").should be_nil
    UCB::LDAP::Org.all_nodes # forces load of cache
    UCB::LDAP::Org.find_by_ou_from_cache("jkasd").deptid.should == 'JKASD'
  end
  
  it "should return flattened_tree" do
    UCB::LDAP::Org.flattened_tree.should be_instance_of(Array)
    UCB::LDAP::Org.flattened_tree.size.should == UCB::LDAP::Org.all_nodes.keys.size
    UCB::LDAP::Org.flattened_tree.first.should equal(UCB::LDAP::Org.root_node)
  end

  it "should return flattened_tree down to certain level" do
    UCB::LDAP::Org.flattened_tree.map { |o| o.level }.sort.last.should == 6
    UCB::LDAP::Org.flattened_tree(:level => 4).map { |o| o.level }.sort.last.should == 4
  end
end


describe "UCB::LDAP::Org instance" do
  before(:all) { UCB::LDAP.host = UCB::LDAP::HOST_PRODUCTION }
  after(:all) { UCB::LDAP.host = HOST_TEST }
  
  before(:each) do
    @e = UCB::LDAP::Org.find_by_ou('jkasd')
  end
  
  it "should return deptid" do
    @e.deptid.should == 'JKASD'
    @e.ou.should == ['JKASD']
  end
  
  it "should return name" do
    @e.name.should == 'Enterprise Application Service'
  end
  
  it "should return processing_unit?" do
    UCB::LDAP::Org.find_by_ou('jkasd').should be_processing_unit
    UCB::LDAP::Org.find_by_ou('UCBKL').should_not be_processing_unit
  end

  it "should return parent_deptids" do
    @e.parent_deptids.should ==  %w{UCBKL AVCIS VRIST} 
  end
  
  it "should return parent_deptid" do
    UCB::LDAP::Org.find_by_ou("avcis").parent_deptid.should == 'UCBKL'
  end

  it "should return level" do
    @e.level.should == 4
  end

  it "should return parent_node" do
    @e.parent_node.deptid.should == 'VRIST'
    UCB::LDAP::Org.root_node.parent_node.should be_nil
  end

  it "should return parent_nodes" do
    @e.parent_deptids.should == @e.parent_nodes.map{|n| n.deptid}
  end

  it "should return child_nodes" do
    r = UCB::LDAP::Org.root_node
    r.child_nodes.should have(13).items
    r.child_nodes.first.deptid.should == 'AVCIS'
    r.child_nodes.last.deptid.should == 'VCURL'
    
    #  test_push_child_node
    o = UCB::LDAP::Org.new({})
    o.child_nodes_i.should be_nil
    
    # add 1
    o.push_child_node(@e)
    o.should have(1).child_nodes_i
    
    # add another
    o.push_child_node(UCB::LDAP::Org.find_by_ou('VCURL'))
    o.should have(2).child_nodes_i
    
    # can't add one a second time
    o.push_child_node(UCB::LDAP::Org.find_by_ou('VCURL'))
    o.should have(2).child_nodes_i
  end

  it "should return child_nodes sorted by deptid" do
    UCB::LDAP::Org.root_node.child_nodes.should == UCB::LDAP::Org.root_node.child_nodes.sort_by { |n| n.deptid }
  end
  
  it "should load department persons" do
    org = UCB::LDAP::Org.find_by_ou('JFAVC')
    org.persons.first.should be_instance_of(UCB::LDAP::Person)
    org.persons.first.deptid.should == 'JFAVC'
  end
end


describe "UCB::LDAP::Org levels" do
  before(:all) do
    UCB::LDAP.host = UCB::LDAP::HOST_PRODUCTION
    @okliv = UCB::LDAP::Org.find_by_ou('okliv')
    @root = UCB::LDAP::Org.root_node
  end
  
  after(:all) do
    UCB::LDAP.host = HOST_TEST
  end
  
  it "should return level_1_org_code, level_1_org_description" do
    @okliv.level_1_code.should == 'UCBKL'
    @okliv.level_1_name.should == 'UC Berkeley Campus'
  end

  it "should return level_2_org_code, level_2_org_description" do
    @okliv.level_2_code.should == 'VCUGA'
    @okliv.level_2_name.should_not be_nil
    @root.level_2_code.should be_nil
    @root.level_2_name.should be_nil
  end

  it "should return level_3_org_code, level_3_org_description" do
    @okliv.level_3_code.should == 'UG1VC'
    @okliv.level_3_name.should_not be_nil
  end

  it "should return level_4_org_code, level_4_org_description" do
    @okliv.level_4_code.should == 'OKLHS'
    @okliv.level_4_name.should_not be_nil
  end

  it "should return level_5_org_code, level_5_org_description" do
    @okliv.level_5_code.should == 'OKCUR'
    @okliv.level_5_name.should_not be_nil
  end

  it "should return level_6_org_code, level_6_org_description" do
    @okliv.level_6_code.should == 'OKLIV'
    @okliv.level_6_name.should_not be_nil
  end
end
