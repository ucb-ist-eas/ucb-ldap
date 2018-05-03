require_relative '../spec_helper'


describe UCB::LDAP::Entry do
  before(:each) do
    allow(Entry).to receive(:entity_name).and_return("org")
    Entry.schema_attributes_array # force load
  end

  it "should make canonical attribute names" do
    expect(Entry.canonical("firstLast")).to eq(:firstlast)
    expect(Entry.canonical("FIRSTLAST")).to eq(:firstlast)
    expect(Entry.canonical(:FIRSTLAST)).to eq(:firstlast)
  end

  it "should return an Array of object_classes" do
    expect(Entry.object_classes).to eq(%w{top organizationalunit berkeleyEduOrgUnit})
  end

  it "should return unique object class" do
    expect(Entry.unique_object_class).to eq('berkeleyEduOrgUnit')
  end

  it "should return an Array of Schema::Attribute" do
    expect(Entry.schema_attributes_array).to be_instance_of(Array)
    expect(Entry.schema_attributes_array[0]).to be_instance_of(Schema::Attribute)
  end

  it "schema_attribute works by name, alias, symbol, any-case version of same" do
    fax_attr = Entry.schema_attributes_array.find { |attr| attr.name == "facsimileTelephoneNumber" }
    expect(fax_attr.aliases).to eq(["fax"])
    ["facsimileTelephoneNumber", "facsimiletelephonenumber",
     "fax", "FAX", :fax].each do |version|
      expect(Entry.schema_attribute(version)).to equal(fax_attr)
    end
  end

  it "should raise exception trying to access bad attribute name" do
    expect(lambda { Entry.schema_attribute("bogus") }).to raise_error(BadAttributeNameException)
  end

  it "should know which of its attributes are required" do
    # commonname is an alias for cn
    # userid is an alias for uid
    # surname is an alias for sn
    # aliases should not show up in the required attributes
    required_person_attributes = [:cn, :objectclass, :sn, :uid]

    TestPerson = Class.new(Entry)
    allow(TestPerson).to receive(:entity_name).and_return("person")
    expect(TestPerson.required_attributes.length).to eq(required_person_attributes.length)
    TestPerson.required_attributes.each do |attr|
      expect(required_person_attributes).to include(attr)
    end
  end
end


describe "UCB::LDAP::Entry instance" do
  before(:each) do
    allow(Entry).to receive(:entity_name).and_return("org")
    Entry.schema_attributes_array # force load
    @e = Entry.new("facsimileTelephoneNumber" => ["1", "2"], :dn => ["dn"])
  end

  it "should make canonical attribute names" do
    expect(@e.canonical("firstLast")).to eq(:firstlast)
    expect(@e.canonical("FIRSTLAST")).to eq(:firstlast)
    expect(@e.canonical(:FIRSTLAST)).to eq(:firstlast)
  end

  it "should return dn (Distinguished Name)" do
    expect(@e.dn).to eq(["dn"])
  end

  it "should raise NoMethodError if bad attribute name treated like method" do
    expect(lambda { @e.bogus }).to raise_error(NoMethodError)
  end

  it "should retrieve values by 'official' attribute name as instance method" do
    expect(@e.facsimileTelephoneNumber).to eq(["1", "2"])
  end

  it "should retrieve values by any-cased name as instance method" do
    expect(@e.facsimiletelephonenumber).to eq(["1", "2"])
  end

  it "should retrieve values by alias" do
    expect(@e.fax).to eq(["1", "2"])
  end

  it "should return scalar result for scalars" do
    @e = Entry.new("berkeleyEduOrgUnitProcessUnitFlag" => ["true"])
    @sa = Entry.schema_attribute("berkeleyEduOrgUnitProcessUnitFlag")
    expect(@e.berkeleyEduOrgUnitProcessUnitFlag).to be true
  end

  it "should return array result for multi-valued attributes" do
    expect(@e.facsimileTelephoneNumber).to eq(["1", "2"])
  end
end


