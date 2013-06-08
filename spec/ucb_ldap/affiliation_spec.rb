require_relative "../spec_helper"


describe "UCB::LDAP::Affiliation" do
  before(:all) do
    affiliation_bind
    @uid = "61065"
    @student = Person.find_by_uid(@uid)
    @datetime_string = '20010203040506Z'
    @datetime_expected = '2001-02-02T20:05:06-08:00'
    @date_expected = '2001-02-02'
  end

  after(:all) do
    UCB::LDAP.clear_authentication
  end

  it "should find affiliations by uid" do
    Affiliation.find_by_uid(@uid).class.should == Array
  end
  
  it "should find affiliations from Person" do
    @student.affiliations.class.should == Array
  end
  
  it "should return create_datetime" do
    Affiliation.new({}).create_datetime.should be_nil
    Affiliation.new(:berkeleyEduAffCreateDate => [@datetime_string]).create_datetime.to_s.should == @datetime_expected
  end
  
  it "should return expired_by" do
    Affiliation.new({}).expired_by.should be_nil
    Affiliation.new(:berkeleyEduAffExpBy => ['foo']).expired_by.to_s.should == 'foo'    
  end
  
  it "should return expiration_date" do
    Affiliation.new({}).expiration_date.should be_nil
    Affiliation.new(:berkeleyEduAffExpDate => [@datetime_string]).expiration_date.to_s.should == @date_expected
  end
  
  it "should return affiliate_id" do
    Affiliation.new({}).affiliate_id.should be_nil
    Affiliation.new(:berkeleyEduAffID => ['foo']).affiliate_id.to_s.should == 'foo'    
  end
  
  it "should return affiliate_type" do
    Affiliation.new({}).affiliate_type.should be_nil
    Affiliation.new(:berkeleyEduAffType => ['foo']).affiliate_type.to_s.should == 'foo'    
  end
  
  it "should return first_name" do
    Affiliation.new({}).first_name.should be_nil
    Affiliation.new(:givenName => ['foo']).first_name.to_s.should == 'foo'    
  end
  
  it "should return middle_name" do
    Affiliation.new({}).middle_name.should be_nil
    Affiliation.new(:berkeleyEduMiddleName => ['foo']).middle_name.to_s.should == 'foo'    
  end
  
  it "should return last_name" do
    Affiliation.new({}).last_name.should be_nil
    Affiliation.new(:sn => ['foo']).last_name.to_s.should == 'foo'    
  end
  
  it "should return modified_by" do
    Affiliation.new({}).modified_by.should be_nil
    Affiliation.new(:berkeleyEduModifiedBy => ['foo']).modified_by.to_s.should == 'foo'    
  end
  
  it "should return source" do
    Affiliation.new({}).source.should be_nil
    Affiliation.new(:berkeleyEduPersonAffiliateSource => ['foo']).source.to_s.should == 'foo'    
  end
  
  it "should return dept_code" do
    Affiliation.new({}).dept_code.should be_nil
    Affiliation.new(:departmentNumber => ['foo']).dept_code.to_s.should == 'foo'    
  end
  
  it "should return dept_name" do
    Affiliation.new({}).dept_name.should be_nil
    Affiliation.new(:berkeleyEduUnitCalNetDeptName => ['foo']).dept_name.to_s.should == 'foo'    
  end
end
