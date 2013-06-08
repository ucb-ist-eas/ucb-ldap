require_relative "../spec_helper"


describe UCB::LDAP::Service do
  before(:all) do
    service_bind
    @student_uid = "61065"
    @student = Person.find_by_uid(@student_uid)
    @dt_str = '20010203080000Z'
    @dt_exp = '2001-02-03T00:00:00-08:00'
  end

  after(:all) do
    UCB::LDAP.clear_authentication
  end

  it "find_by_uid(uid) should return terms" do
    Service.find_by_uid(@student_uid).class.should == Array
  end
  
  it "Person should find services" do
    @student.services.class.should == Array
  end
  
  it "should return eligible_by" do
    Service.new({}).eligible_by.should be_nil
    Service.new({:berkeleyEduPersonServiceEligibleBy => ['foo']}).eligible_by.should == 'foo'
  end
  
  it "should return eligible_date" do
    Service.new({}).eligible_date.should be_nil
    s = Service.new({:berkeleyEduPersonServiceEligibleDate => [@dt_str]})
    s.eligible_date.class.should == DateTime
    s.eligible_date.to_s.should == @dt_exp
  end
  
  it "should return ended_by" do
    Service.new({}).ended_by.should be_nil
    Service.new({:berkeleyEduPersonServiceEndBy => ['foo']}).ended_by.should == 'foo'
  end
  
  it "should return end_date" do
    Service.new({}).end_date.should be_nil
    s = Service.new({:berkeleyEduPersonServiceEndDate => [@dt_str]})
    s.end_date.class.should == DateTime
    s.end_date.to_s.should == @dt_exp
  end
  
  it "should return entered_by" do
    Service.new({}).entered_by.should be_nil
    Service.new({:berkeleyEduPersonServiceEnteredBy => ['foo']}).entered_by.should == 'foo'
  end
  
  it "should return entered_date" do
    Service.new({}).entered_date.should be_nil
    s = Service.new({:berkeleyEduPersonServiceEnteredDate => [@dt_str]})
    s.entered_date.class.should == DateTime
    s.entered_date.to_s.should == @dt_exp
  end
  
  it "should return level" do
    Service.new({}).level.should be_nil
    Service.new({:berkeleyEduPersonServiceLevel => ['42']}).level.should == 42
  end
  
  it "should return modified_by" do
    Service.new({}).modified_by.should be_nil
    Service.new({:berkeleyEduPersonServiceModifiedBy => ['foo']}).modified_by.should == 'foo'
  end
  
  it "should return modified_date" do
    Service.new({}).modified_date.should be_nil
    s = Service.new({:berkeleyEduPersonServiceModifiedDate => [@dt_str]})
    s.modified_date.class.should == DateTime
    s.modified_date.to_s.should == @dt_exp
  end
  
  it "should return naughty_bit" do
    Service.new({}).naughty_bit.should be_false
    Service.new({:berkeleyEduPersonServiceNaughtyBit => ['true']}).naughty_bit.should be_true
  end
  
  it "should return notified_by" do
    Service.new({}).notified_by.should be_nil
    Service.new({:berkeleyEduPersonServiceNotifyBy => ['foo']}).notified_by.should == 'foo'
  end
  
  it "should return notify_date" do
    Service.new({}).notify_date.should be_nil
    s = Service.new({:berkeleyEduPersonServiceNotifyDate => [@dt_str]})
    s.notify_date.class.should == DateTime
    s.notify_date.to_s.should == @dt_exp
  end
  
  it "should return stopped_by" do
    Service.new({}).stopped_by.should be_nil
    Service.new({:berkeleyEduPersonServiceStopBy => ['foo']}).stopped_by.should == 'foo'
  end
  
  it "should return stop_date" do
    Service.new({}).stop_date.should be_nil
    s = Service.new({:berkeleyEduPersonServiceStopDate => [@dt_str]})
    s.stop_date.class.should == DateTime
    s.stop_date.to_s.should == @dt_exp
  end
  
  it "should return value" do
    Service.new({}).value.should be_nil
    Service.new({:berkeleyEduPersonServiceValue => ['foo']}).value.should == 'foo'
  end
  
  it "should return service" do
    Service.new({}).service.should be_nil
    Service.new({:berkeleyEduService => ['foo']}).service.should == 'foo'
  end
  
  it "should return common_name" do
    Service.new({}).common_name.should == []
    Service.new({:cn => ['foo']}).common_name.should == ['foo']
  end
  
  it "should return description" do
    Service.new({}).description.should be_nil
    Service.new({:description => ['foo']}).description.should == 'foo'
  end
end
  
