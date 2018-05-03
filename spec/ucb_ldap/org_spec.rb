require_relative "../spec_helper"

# NOTE
# These specs rely on live data in the production LDAP server, which changes from time to time. If
# it becomes to troublesome to keep these specs up-to-date, they might not be worth keeping.

describe UCB::LDAP::Org do
  it "should set tree base" do
    expect(UCB::LDAP::Org.tree_base).to eq('ou=org units,dc=berkeley,dc=edu')
  end

  it "should set entity name" do
    expect(UCB::LDAP::Org.entity_name).to eq("org")
  end

  it "should set schema attributes" do
    expect(UCB::LDAP::Org.schema_attributes_array).to be_instance_of(Array)
    expect(UCB::LDAP::Org.schema_attributes_array[0]).to be_instance_of(UCB::LDAP::Schema::Attribute)
    ou_attr = UCB::LDAP::Org.schema_attribute(:ou)
  end

  it "find_by_ou should fetch Org instance" do
    UCB::LDAP::Org.clear_all_nodes
    e = UCB::LDAP::Org.find_by_ou('jkasd')
    expect(e).to be_instance_of(UCB::LDAP::Org)
    expect(e.ou).to eq(['JKASD'])
    # verify cache empty
    expect(UCB::LDAP::Org.all_nodes_i).to be_nil
  end

  it 'org_by_ou is alias for find_by_ou' do
    e = UCB::LDAP::Org.org_by_ou('jkasd')
    expect(e).to be_instance_of(UCB::LDAP::Org)
  end

  it 'search should return Array of UCB::LDAP::Org' do
    entries = UCB::LDAP::Org.search(:filter => {:ou => 'jkasd'})
    expect(entries).to be_instance_of(Array)
    expect(entries[0]).to be_instance_of(UCB::LDAP::Org)
  end

  it 'root_node should return the root node' do
    expect(UCB::LDAP::Org.root_node.deptid).to eq('UCBKL')
  end

  it "should load_all_nodes" do
    UCB::LDAP::Org.clear_all_nodes
    expect(UCB::LDAP::Org.all_nodes_i).to be_nil
    UCB::LDAP::Org.load_all_nodes
    expect(UCB::LDAP::Org.all_nodes_i.keys.count).to be >= 1000
  end

  it "should return Array of all org nodes when sent all_nodes()" do
    all_nodes = UCB::LDAP::Org.all_nodes
    expect(all_nodes.keys.count).to be >= 1000
    expect(all_nodes[all_nodes.keys.first]).to be_instance_of(UCB::LDAP::Org)
  end

  it "should cache the org tree" do
    UCB::LDAP::Org.clear_all_nodes
    expect(UCB::LDAP::Org.all_nodes_i).to be_nil
    UCB::LDAP::Org.all_nodes
    expect(UCB::LDAP::Org.all_nodes_i).not_to be_nil
    # In the future, additional nodes may be added or deleted directly beneath
    # the root node, in which case this test would fail need to be altered.
    expect(UCB::LDAP::Org.root_node.child_nodes_i.count).to eq(10)
  end

  it "should be able to fetch orgs from cache" do
    UCB::LDAP::Org.clear_all_nodes
    expect(UCB::LDAP::Org.find_by_ou_from_cache("jkasd")).to be_nil
    UCB::LDAP::Org.all_nodes # forces load of cache
    expect(UCB::LDAP::Org.find_by_ou_from_cache("jkasd").deptid).to eq('JKASD')
  end

  it "should return flattened_tree" do
    expect(UCB::LDAP::Org.flattened_tree).to be_instance_of(Array)
    expect(UCB::LDAP::Org.flattened_tree.size).to eq(UCB::LDAP::Org.all_nodes.keys.size)
    expect(UCB::LDAP::Org.flattened_tree.first).to eq(UCB::LDAP::Org.root_node)
  end

  it "should return flattened_tree down to certain level" do
    expect(UCB::LDAP::Org.flattened_tree.map { |o| o.level }.sort.last).to eq(6)
    expect(UCB::LDAP::Org.flattened_tree(:level => 4).map { |o| o.level }.sort.last).to eq(4)
  end
end


describe "UCB::LDAP::Org instance" do

  before(:each) do
    @e = UCB::LDAP::Org.find_by_ou('jkasd')
  end

  it "should return deptid" do
    expect(@e.deptid).to eq('JKASD')
    expect(@e.ou).to eq(['JKASD'])
  end

  it "should return name" do
    expect(@e.name).to eq('Administrative IT Solutions')
  end

  it "should return processing_unit?" do
    expect(UCB::LDAP::Org.find_by_ou('UCBKL')).not_to be_processing_unit
    expect(UCB::LDAP::Org.find_by_ou('jkasd')).not_to be_processing_unit
    expect(UCB::LDAP::Org.find_by_ou('yavpr')).to be_processing_unit
  end

  it "should return parent_deptids" do
    expect(@e.parent_deptids).to eq(%w{UCBKL CAMSU VCBAS VRIST})
  end

  it "should return parent_deptid" do
    expect(UCB::LDAP::Org.find_by_ou("CAMSU").parent_deptid).to eq('UCBKL')
  end

  it "should return level" do
    expect(@e.level).to eq(5)
  end

  it "should return parent_node" do
    expect(@e.parent_node.deptid).to eq('VRIST')
    expect(UCB::LDAP::Org.root_node.parent_node).to be_nil
  end

  it "should return parent_nodes" do
    expect(@e.parent_deptids).to eq(@e.parent_nodes.map{|n| n.deptid})
  end

  it "should return child_nodes" do
    r = UCB::LDAP::Org.root_node
    expect(r.child_nodes.count).to eq(10)
    expect(r.child_nodes.first.deptid).to eq('CAMSU')
    expect(r.child_nodes.last.deptid).to eq('VCRES')

    #  test_push_child_node
    o = UCB::LDAP::Org.new({})
    expect(o.child_nodes_i).to be_nil

    # add 1
    o.push_child_node(@e)
    expect(o.child_nodes_i.count).to eq(1)

    # add another
    o.push_child_node(UCB::LDAP::Org.find_by_ou('VCRES'))
    expect(o.child_nodes_i.count).to eq(2)

    # can't add one a second time
    o.push_child_node(UCB::LDAP::Org.find_by_ou('VCRES'))
    expect(o.child_nodes_i.count).to eq(2)
  end

  it "should return child_nodes sorted by deptid" do
    expect(UCB::LDAP::Org.root_node.child_nodes).to eq(UCB::LDAP::Org.root_node.child_nodes.sort_by { |n| n.deptid })
  end

  it "should load department persons" do
    org = UCB::LDAP::Org.find_by_ou('JFAVC')
    expect(org.persons.first).to be_instance_of(UCB::LDAP::Person)
    expect(org.persons.first.deptid).to eq('JFAVC')
  end
end


describe "UCB::LDAP::Org levels" do
  before(:all) do
    @level_6 = UCB::LDAP::Org.find_by_ou('AZAD6')
    @root = UCB::LDAP::Org.root_node
  end

  it "should return level_1_org_code, level_1_org_description" do
    expect(@level_6.level_1_code).to eq('UCBKL')
    expect(@level_6.level_1_name).to eq('UC Berkeley Campus')
  end

  it "should return level_2_org_code, level_2_org_description" do
    expect(@level_6.level_2_code).to eq('CAMSU')
    expect(@level_6.level_2_name).not_to be_nil
    expect(@root.level_2_code).to be_nil
    expect(@root.level_2_name).to be_nil
  end

  it "should return level_3_org_code, level_3_org_description" do
    expect(@level_6.level_3_code).to eq('VCBAS')
    expect(@level_6.level_3_name).not_to be_nil
  end

  it "should return level_4_org_code, level_4_org_description" do
    expect(@level_6.level_4_code).to eq('AZCSS')
    expect(@level_6.level_4_name).not_to be_nil
  end

  it "should return level_5_org_code, level_5_org_description" do
    expect(@level_6.level_5_code).to eq('AZADM')
    expect(@level_6.level_5_name).not_to be_nil
  end

  it "should return level_6_org_code, level_6_org_description" do
    expect(@level_6.level_6_code).to eq('AZAD6')
    expect(@level_6.level_6_name).not_to be_nil
  end
end
