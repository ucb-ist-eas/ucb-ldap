require File.expand_path("#{File.dirname(__FILE__)}/_setup")


describe "The UCB::LDAP::Schema::Attribute constructor" do
  it "should set name instance variable" do
    UCB::LDAP::Schema::Attribute.new("name" => "attr_name").name.should == "attr_name"
  end

  it "should set type instance variable" do
    UCB::LDAP::Schema::Attribute.new("syntax" => "string").type.should == "string"
  end

  it "should set description instance variable" do
    UCB::LDAP::Schema::Attribute.new("description" => "attr_descr").description.should == "attr_descr"
  end

  it "should aliases instance variable (empty and present)" do
    UCB::LDAP::Schema::Attribute.new({}).aliases.should == []
    UCB::LDAP::Schema::Attribute.new("aliases" => ["a", "b"]).aliases.should == ["a", "b"]
  end
  
  it "should set required instance variable" do
    UCB::LDAP::Schema::Attribute.new("required" => true).required?.should be_true
    UCB::LDAP::Schema::Attribute.new("required" => false).required?.should be_false
  end

  it "should set multi_valued instance variable" do
    UCB::LDAP::Schema::Attribute.new("multi" => true).multi_valued?.should be_true
    UCB::LDAP::Schema::Attribute.new("multi" => false).multi_valued?.should be_false
  end
end


describe "Schema::Attribute get_value() for multi_valued" do
  it "should return array when multi_valued" do
    Schema::Attribute.new("multi" => true, "syntax" => "string").get_value(%w{1 2}).should == %w{1 2}
  end

  it "should return empty array when multi_valued and no value" do
    Schema::Attribute.new("multi" => true, "syntax" => "string").get_value(nil).should == []
  end
end


describe "Schema::Attribute get_value() for not multi_valued" do
  it "should return scalar when not multi_valued" do
    Schema::Attribute.new("multi" => false, "syntax" => "string").get_value(%w{1}).should == "1"
  end

  it "should return nil when not multi_valued and no value" do
    Schema::Attribute.new("multi" => false).get_value(nil).should be_nil
  end
end


describe "Schema::Attribute get_value() for string" do
  it "returns string" do
    Schema::Attribute.new("syntax" => "string", "multi" => true).get_value(%w{1 2}).should == ["1", "2"]
    Schema::Attribute.new("syntax" => "string", "multi" => false).get_value(%w{1}).should == "1"
  end
end


describe "Schema::Attribute get_value() for integer" do
  it "returns integer" do
    Schema::Attribute.new("syntax" => "integer", "multi" => true).get_value(%w{1 2}).should == [1, 2]
    Schema::Attribute.new("syntax" => "integer", "multi" => false).get_value(%w{1}).should == 1
  end
end


describe "Schema::Attribute get_value() for boolean" do
  it "returns boolean" do
    Schema::Attribute.new("syntax" => "boolean").get_value(["true"]).should be_true
    Schema::Attribute.new("syntax" => "boolean").get_value(["1"]).should be_true
    Schema::Attribute.new("syntax" => "boolean").get_value(["false"]).should be_false
    Schema::Attribute.new("syntax" => "boolean").get_value([""]).should be_false
    Schema::Attribute.new("syntax" => "boolean").get_value(nil).should be_false
  end
end


describe "Schema::Attribute get_value() for timestamp" do
  it "returns Date" do
    schema_attribute = Schema::Attribute.new("syntax" => "timestamp")
    datetime = schema_attribute.get_value(["19980101123456Z"])
    datetime.class.should == DateTime
    datetime.to_s.should == "1998-01-01T04:34:56-08:00"
    
    schema_attribute.get_value(nil).should be_nil
  end
end


describe "Schema::Attribute ldap_value()" do
  before do
    @a = Schema::Attribute.new({})
  end
  
  it "should return an Array when given an Array" do
    @a.ldap_value(["foo"]).should == ["foo"]  
  end
  
  it "should return an Array when given a scalar" do
    @a.ldap_value("foo").should == ["foo"]
  end
  
  it "should return Array of String regardless of input type" do
    @a.ldap_value(1).should == ["1"]
    @a.ldap_value([1, true, "three"]).should == ["1", "true", "three"]
  end
  
  it "should return nil when passed nil" do
    @a.ldap_value(nil).should be_nil
  end

  it "should remove leading/trailing spaces, any newlines" do
    @a.ldap_value(' foo').should == ['foo']  
    @a.ldap_value('foo ').should == ['foo']  
    @a.ldap_value("f\noo").should == ['foo']  
  end
end
