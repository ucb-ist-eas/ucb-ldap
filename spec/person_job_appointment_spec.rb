require File.expand_path("#{File.dirname(__FILE__)}/_setup")


describe "UCB::LDAP::JobAppointment" do
  before(:all) do
    job_appointment_bind() # in _setup_specs.rb
    @sh_appts = JobAppointment.find_by_uid('61065')
    @sh_appt = @sh_appts.first
  end

  after(:all) do
    UCB::LDAP.clear_authentication
  end
  
  it "should find job appointments by uid" do
    @sh_appts.should be_instance_of(Array)
    @sh_appts.first.should be_instance_of(JobAppointment)
    @sh_appts.size.should == 1
  end
  
  it "should return cto code" do
    @sh_appt.cto_code.should == 'F15'
  end
  
  it "should return deptid" do
    @sh_appt.deptid.should == 'JKASD'
  end
  
  it "should return record number" do
    @sh_appt.record_number.should == 0
  end
  
  it "should return Personnel Program Code" do
    @sh_appt.personnel_program_code.should == "1"
  end
  
  it "should return primary? flag" do
    @sh_appt.should be_primary
  end
  
  it "should return primary? flag" do
    @sh_appt.should be_primary
  end
  
  it "should return ERC code" do
    @sh_appt.erc_code.should == "E"
  end
  
  it "should return represented? flag" do
    @sh_appt.should_not be_represented
  end
  
  it "should return title code" do
    @sh_appt.title_code.should == '7316'
  end
  
  it "should return appointment type" do
    @sh_appt.appointment_type.should == '2'
  end
  
  it "should return wos? flag" do
    @sh_appt.should_not be_wos
  end
  
end

