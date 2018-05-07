require_relative "../spec_helper"


describe "The UCB::LDAP::Schema::Attribute constructor" do
  it "should set name instance variable" do
    expect(UCB::LDAP::Schema::Attribute.new("name" => "attr_name").name).to eq("attr_name")
  end

  it "should set type instance variable" do
    expect(UCB::LDAP::Schema::Attribute.new("syntax" => "string").type).to eq("string")
  end

  it "should set description instance variable" do
    expect(UCB::LDAP::Schema::Attribute.new("description" => "attr_descr").description).to eq("attr_descr")
  end

  it "should aliases instance variable (empty and present)" do
    expect(UCB::LDAP::Schema::Attribute.new({}).aliases).to eq([])
    expect(UCB::LDAP::Schema::Attribute.new("aliases" => ["a", "b"]).aliases).to eq(["a", "b"])
  end

  it "should set required instance variable" do
    expect(UCB::LDAP::Schema::Attribute.new("required" => true).required?).to be true
    expect(UCB::LDAP::Schema::Attribute.new("required" => false).required?).to be false
  end

  it "should set multi_valued instance variable" do
    expect(UCB::LDAP::Schema::Attribute.new("multi" => true).multi_valued?).to be true
    expect(UCB::LDAP::Schema::Attribute.new("multi" => false).multi_valued?).to be false
  end
end


describe "Schema::Attribute get_value() for multi_valued" do
  it "should return array when multi_valued" do
    expect(Schema::Attribute.new("multi" => true, "syntax" => "string").get_value(%w{1 2})).to eq(%w{1 2})
  end

  it "should return empty array when multi_valued and no value" do
    expect(Schema::Attribute.new("multi" => true, "syntax" => "string").get_value(nil)).to eq([])
  end
end


describe "Schema::Attribute get_value() for not multi_valued" do
  it "should return scalar when not multi_valued" do
    expect(Schema::Attribute.new("multi" => false, "syntax" => "string").get_value(%w{1})).to eq("1")
  end

  it "should return nil when not multi_valued and no value" do
    expect(Schema::Attribute.new("multi" => false).get_value(nil)).to be_nil
  end
end


describe "Schema::Attribute get_value() for string" do
  it "returns string" do
    expect(Schema::Attribute.new("syntax" => "string", "multi" => true).get_value(%w{1 2})).to eq(["1", "2"])
    expect(Schema::Attribute.new("syntax" => "string", "multi" => false).get_value(%w{1})).to eq("1")
  end
end


describe "Schema::Attribute get_value() for integer" do
  it "returns integer" do
    expect(Schema::Attribute.new("syntax" => "integer", "multi" => true).get_value(%w{1 2})).to eq([1, 2])
    expect(Schema::Attribute.new("syntax" => "integer", "multi" => false).get_value(%w{1})).to eq(1)
  end
end


describe "Schema::Attribute get_value() for boolean" do
  it "returns boolean" do
    expect(Schema::Attribute.new("syntax" => "boolean").get_value(["true"])).to be true
    expect(Schema::Attribute.new("syntax" => "boolean").get_value(["1"])).to be true
    expect(Schema::Attribute.new("syntax" => "boolean").get_value(["false"])).to be false
    expect(Schema::Attribute.new("syntax" => "boolean").get_value([""])).to be false
    expect(Schema::Attribute.new("syntax" => "boolean").get_value(nil)).to be false
  end
end


describe "Schema::Attribute get_value() for timestamp" do
  it "returns Date" do
    schema_attribute = Schema::Attribute.new("syntax" => "timestamp")
    datetime = schema_attribute.get_value(["19980101123456Z"])
    expect(datetime.class).to eq(DateTime)
    expect(datetime.to_s).to eq("1998-01-01T04:34:56-08:00")

    expect(schema_attribute.get_value(nil)).to be_nil
  end
end


describe "Schema::Attribute ldap_value()" do
  before do
    @a = Schema::Attribute.new({})
  end

  it "should return an Array when given an Array" do
    expect(@a.ldap_value(["foo"])).to eq(["foo"])
  end

  it "should return an Array when given a scalar" do
    expect(@a.ldap_value("foo")).to eq(["foo"])
  end

  it "should return Array of String regardless of input type" do
    expect(@a.ldap_value(1)).to eq(["1"])
    expect(@a.ldap_value([1, true, "three"])).to eq(["1", "true", "three"])
  end

  it "should return nil when passed nil" do
    expect(@a.ldap_value(nil)).to be_nil
  end

  it "should remove leading/trailing spaces, any newlines" do
    expect(@a.ldap_value(' foo')).to eq(['foo'])
    expect(@a.ldap_value('foo ')).to eq(['foo'])
    expect(@a.ldap_value("f\noo")).to eq(['foo'])
  end
end
