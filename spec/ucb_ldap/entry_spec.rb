require_relative '../spec_helper'


describe UCB::LDAP::Entry do
  before(:each) do
    Entry.stub!(:entity_name).and_return("org")
    Entry.schema_attributes_array # force load
  end

  it "should make canonical attribute names" do
    Entry.canonical("firstLast").should == :firstlast
    Entry.canonical("FIRSTLAST").should == :firstlast
    Entry.canonical(:FIRSTLAST).should == :firstlast
  end

  it "should return an Array of object_classes" do
    Entry.object_classes.should == %w{top organizationalunit berkeleyEduOrgUnit}
  end

  it "should return unique object class" do
    Entry.unique_object_class.should == 'berkeleyEduOrgUnit'
  end

  it "should return an Array of Schema::Attribute" do
    Entry.schema_attributes_array.should be_instance_of(Array)
    Entry.schema_attributes_array[0].should be_instance_of(Schema::Attribute)
  end

  it "schema_attribute works by name, alias, symbol, any-case version of same" do
    fax_attr = Entry.schema_attributes_array.find { |attr| attr.name == "facsimileTelephoneNumber" }
    fax_attr.aliases.should == ["fax"]
    ["facsimileTelephoneNumber", "facsimiletelephonenumber",
     "fax", "FAX", :fax].each do |version|
      Entry.schema_attribute(version).should equal(fax_attr)
    end
  end

  it "should raise exception trying to access bad attribute name" do
    lambda { Entry.schema_attribute("bogus") }.should raise_error(BadAttributeNameException)
  end

  it "should know which of its attributes are required" do
    # commonname is an alias for cn
    # userid is an alias for uid
    # surname is an alias for sn
    # aliases should not show up in the required attributes
    required_person_attributes = [:cn, :objectclass, :sn, :uid]

    TestPerson = Class.new(Entry)
    TestPerson.stub!(:entity_name).and_return("person")
    TestPerson.required_attributes.length.should == required_person_attributes.length
    TestPerson.required_attributes.each do |attr|
      required_person_attributes.should include(attr)
    end
  end
end


describe "UCB::LDAP::Entry instance" do
  before(:each) do
    Entry.stub!(:entity_name).and_return("org")
    Entry.schema_attributes_array # force load
    @e = Entry.new("facsimileTelephoneNumber" => ["1", "2"], :dn => ["dn"])
  end

  it "should make canonical attribute names" do
    @e.canonical("firstLast").should == :firstlast
    @e.canonical("FIRSTLAST").should == :firstlast
    @e.canonical(:FIRSTLAST).should == :firstlast
  end

  it "should return dn (Distinguished Name)" do
    @e.dn.should == ["dn"]
  end

  it "should raise NoMethodError if bad attribute name treated like method" do
    lambda { @e.bogus }.should raise_error(NoMethodError)
  end

  it "should retrieve values by 'official' attribute name as instance method" do
    @e.facsimileTelephoneNumber.should == ["1", "2"]
  end

  it "should retrieve values by any-cased name as instance method" do
    @e.facsimiletelephonenumber.should == ["1", "2"]
  end

  it "should retrieve values by alias" do
    @e.fax.should == ["1", "2"]
  end

  it "should return scalar result for scalars" do
    @e = Entry.new("berkeleyEduOrgUnitProcessUnitFlag" => ["true"])
    @sa = Entry.schema_attribute("berkeleyEduOrgUnitProcessUnitFlag")
    @e.berkeleyEduOrgUnitProcessUnitFlag.should be_true
  end

  it "should return array result for multi-valued attributes" do
    @e.facsimileTelephoneNumber.should == ["1", "2"]
  end

  it "setter methods end in '='" do
    @e.send(:setter_method?, :foo=).should be_true
    @e.send(:setter_method?, "foo=").should be_true
    @e.send(:setter_method?, :foo).should be_false
    @e.send(:setter_method?, "foo").should be_false
  end
end


describe "Setting UCB::LDAP::Namespace attributes" do
  before(:all) do
    namespace_bind # _setup_specs.rb
  end

  before(:each) do
    @namespace = Namespace.find_by_uid("61065").first
  end

  after(:all) do
    UCB::LDAP.clear_authentication
  end

  it "should set assigned attributes when set w/scalar" do
    @namespace.cn = "a_name"
    @namespace.assigned_attributes[:cn].should == ["a_name"]
  end

  it "should set assigned attributes when set w/array" do
    @namespace.cn = ["a", "b"]
    @namespace.assigned_attributes[:cn].should == ["a", "b"]
  end

  it "should set assigned attributes when set w/nil" do
    @namespace.cn = nil
    @namespace.assigned_attributes[:cn].should be_nil
  end

  it "should trim leading/trailing spaces and imbedded newlines" do
    @namespace.cn = " foo\nbar "
    @namespace.assigned_attributes[:cn].should == ['foobar']
  end

  it "should set modify operations correctly" do
    @namespace.cn = ["CN"]
    @namespace.uid = nil
    @namespace.berkeleyEduServices = ["s1", "s2"]
    @namespace.modify_operations.should == [
        [:replace, :berkeleyeduservices, ["s1", "s2"]],
        [:replace, :cn, ["CN"]],
        [:delete, :uid, nil]
    ]
  end
end


describe "Updating UCB::LDAP::Namespace entries" do
  before(:all) do
    UCB::LDAP.host == HOST_TEST
    namespace_bind
  end

  before(:each) do
    @uid = '61065'
    @cn = 'test_add'
    @dn_base = 'ou=names,ou=namespace,dc=berkeley,dc=edu'
    delete_by_cn(@cn)
  end

  after(:all) do
    UCB::LDAP.clear_authentication
  end

  def delete_by_cn(cn)
    Namespace.find_by_cn(cn).delete rescue nil
  end

  def add_entry(cn, services="calnet", method="create")
    dn = "cn=#{cn},#{@dn_base}"
    attrs = { :cn => @cn, :berkeleyEduServices => services, :uid => @uid }
    Namespace.send(method, :dn => dn, :attributes => attrs)
  end

  it "create should return new entry on success, false on failure" do
    pending "Need to Fix Ldap Permissions"

    Namespace.find_by_cn(@cn).should be_nil
    ns = add_entry(@cn)
    ns.class.should == Namespace
    ns.cn.should == [@cn]
    ns.services.should == ['calnet']
    add_entry(@cn).should be_false
  end

  it "create! should return new entry on success, raise error on failure" do
    pending "Need to Fix Ldap Permissions"

    Namespace.find_by_cn(@cn).should be_nil
    ns = add_entry(@cn, 'calmail', "create!")
    ns.should be_instance_of(Namespace)
    ns.cn.should == [@cn]
    lambda { add_entry(@cn, 'calnet', "create!") }.should raise_error(DirectoryNotUpdatedException)
  end

  it "update_attributes should return true on success, false on failure" do
    pending "Need to Fix Ldap Permissions"

    ns = add_entry(@cn)
    ns.services.should == ['calnet']
    ns.update_attributes(:berkeleyEduServices => ['calmail', 'calnet']).should be_true
    ns.services.should == ['calmail', 'calnet']
    ns.update_attributes(:berkeleyEduServices => ["calmail", "calmail"]).should be_false
  end

  it "update_attributes! should raise error on failure" do
    pending "Need to Fix Ldap Permissions"

    ns = add_entry(@cn)
    ns.services.should == ['calnet']
    ns.update_attributes!(:berkeleyEduServices => "calmail").should be_true
    ns.services.should == ['calmail']
    lambda { ns.update_attributes!(:berkeleyEduServices => ["calmail", "calmail"]) }.should raise_error(DirectoryNotUpdatedException)
  end

  it "delete should return true on success and false on failure" do
    pending "Need to Fix Ldap Permissions"

    ns = add_entry(@cn)
    ns.delete.should be_true
    ns.delete.should be_false
  end

  it "delete! should return true on success, raise DirectoryNotUpdated on failure" do
    pending "Need to Fix Ldap Permissions"

    ns = add_entry(@cn)
    ns.delete!.should be_true
    lambda { ns.delete! }.should raise_error(DirectoryNotUpdatedException)
  end
end

