require_relative "../spec_helper"


describe "UCB::LDAP::Affiliation" do
  before(:all) do
    @uid = "232588"
    @student = Person.find_by_uid(@uid)
    @datetime_string = '20010203040506Z'
    @datetime_expected = '2001-02-02T20:05:06-08:00'
    @date_expected = '2001-02-02'
  end

  it "should find affiliations by uid" do
    expect(Affiliation.find_by_uid(@uid)).to be_instance_of(Array)
  end

  it "should find affiliations from Person" do
    expect(@student.affiliations.class).to eq(Array)
  end

  it "should return expired_by" do
    expect(Affiliation.new({}).expired_by).to be_nil
    expect(Affiliation.new(:berkeleyEduAffExpBy => ['foo']).expired_by.to_s).to eq('foo')
  end

  it "should return affiliate_id" do
    expect(Affiliation.new({}).affiliate_id).to be_nil
    expect(Affiliation.new(:berkeleyEduAffID => ['foo']).affiliate_id.to_s).to eq('foo')
  end

  it "should return affiliate_type" do
    expect(Affiliation.new({}).affiliate_type).to be_nil
    expect(Affiliation.new(:berkeleyEduAffType => ['foo']).affiliate_type.to_s).to eq('foo')
  end

  it "should return first_name" do
    expect(Affiliation.new({}).first_name).to be_nil
    expect(Affiliation.new(:givenName => ['foo']).first_name.to_s).to eq('foo')
  end

  it "should return middle_name" do
    expect(Affiliation.new({}).middle_name).to be_nil
    expect(Affiliation.new(:berkeleyEduMiddleName => ['foo']).middle_name.to_s).to eq('foo')
  end

  it "should return last_name" do
    expect(Affiliation.new({}).last_name).to be_nil
    expect(Affiliation.new(:sn => ['foo']).last_name.to_s).to eq('foo')
  end

  it "should return modified_by" do
    expect(Affiliation.new({}).modified_by).to be_nil
    expect(Affiliation.new(:berkeleyEduModifiedBy => ['foo']).modified_by.to_s).to eq('foo')
  end

  it "should return source" do
    expect(Affiliation.new({}).source).to be_nil
    expect(Affiliation.new(:berkeleyEduPersonAffiliateSource => ['foo']).source.to_s).to eq('foo')
  end

  it "should return dept_code" do
    expect(Affiliation.new({}).dept_code).to be_nil
    expect(Affiliation.new(:departmentNumber => ['foo']).dept_code.to_s).to eq('foo')
  end
end
