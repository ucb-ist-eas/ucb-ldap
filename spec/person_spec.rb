require File.expand_path("#{File.dirname(__FILE__)}/_setup")


describe UCB::LDAP::Person, "searching for test entries" do
  it "excludes test entries by default" do
    Person.instance_variable_set(:@include_test_entries, nil)
    Person.include_test_entries?.should be_false
    Person.find_by_uid("212387").should be_nil
  end
  
  it "allows for test entries to be included" do
    Person.include_test_entries = true
    Person.include_test_entries?.should be_true
    Person.find_by_uid("212387").uid.should == "212387"
  end
end


describe UCB::LDAP::Person do
  before(:all) do
    Person.include_test_entries = true
    @staff = Person.find_by_uid "212387"
    @student = Person.find_by_uid "232588"
  end
  
  it "constructor should return Person instances" do
    @staff.should be_instance_of(Person)
    @student.should be_instance_of(Person)
  end
  
  it "persons_by_uid should return Array of Person" do
    persons = Person.find_by_uids ['212386', '212387']
    persons.should be_instance_of(Array)
    persons.should have(2).items
    persons[0].should be_instance_of(Person)
    persons[0].uid.should == '212386'
    persons[1].uid.should == '212387'
    
    Person.persons_by_uids([]).should == []
  end

  it "find_by_uid(s) is an alias for person(s)_by_uid" do
    Person.respond_to?(:find_by_uids).should be_true
    Person.respond_to?(:find_by_uid).should be_true
  end

  it "find_by_uid works with a String or an Integer" do
    staff_from_int_uid = Person.find_by_uid(212387)
    staff_from_int_uid.uid.should == @staff.uid
  end
end


describe "UCB::LDAP::Person instance" do
  before(:all) do
    UCB::LDAP::Person.include_test_entries = true
    @staff = Person.find_by_uid("212387")
    @student = Person.find_by_uid("232588")
  end
  
  it "should know if an person is a test entry" do
    @staff.test?.should be_true
    Person.find_by_uid('61065').test?.should_not be_true
  end
  
  it "should return uid as scalar" do
    @staff.uid.should == "212387"
  end
  
  it "should return firstname and first_name as (scalar) synonyms for givenname" do
    @staff.givenname.should == ['EMP-STAFF']
    @staff.firstname.should == 'EMP-STAFF'
    @staff.first_name.should == 'EMP-STAFF'
  end
  
  it "should return lastname and last_name as (scalar) synonyms for sn" do
    @staff.sn.should == ['TEST']
    @staff.lastname.should == 'TEST'
    @staff.last_name.should == 'TEST'
  end
  
  it "should return email as scalar synonym for mail" do
    @staff.mail.should == ['test@uclink.berkeley.edu'] 
    @staff.email.should == 'test@uclink.berkeley.edu' 
  end
  
  it "should return phone as scalar synonym for telephoneNumber" do
    @staff.telephoneNumber.should == ['+1 (510) 643-1234'] 
    @staff.phone.should == '+1 (510) 643-1234' 
  end

  it "should return deptid, dept_code as scalar synonym for berkeleyEduPrimaryDeptUnit" do
    @staff.berkeleyEduPrimaryDeptUnit.should == 'JICCS' 
    @staff.deptid.should == 'JICCS' 
    @staff.dept_code.should == 'JICCS'
  end

  it "should return dept_name as scalar synonym for berkeleyEduUnitCalNetDeptName" do
    # here we aren't using a test entry as no test entires have values
    # for the below attributes
    p = UCB::LDAP::Person.find_by_uid(61065)
    p.berkeleyEduUnitCalNetDeptName.should == "IST-Application Services"
    p.dept_name.should == "IST-Application Services"
  end

  it "should return org_node (UCB::LDAP::Org instance)" do
    @staff.org_node.should be_instance_of(Org) 
    @staff.org_node.deptid.should == 'JICCS'
  end
  
  it "should return affiliations" do
    @staff.affiliations.should include('EMPLOYEE-TYPE-STAFF')
    @student.affiliations.should include('STUDENT-TYPE-REGISTERED')
    
    @staff.has_affiliation?("bogus").should be_false
    @staff.has_affiliation?('EMPLOYEE-TYPE-STAFF').should be_true
    @staff.has_affiliation?('employee-type-staff').should be_true
    
    @student.has_affiliation?("bogus").should be_false
    @student.has_affiliation?('STUDENT-TYPE-REGISTERED').should be_true
    @student.has_affiliation?('student-type-registered').should be_true
  end
  
  it "should return has_affiliation_of_type?()" do
    Person.new({}).has_affiliation_of_type?(:affiliate).should be_false
    Person.new({:berkeleyEduAffiliations => ["AFFILIATE-TYPE-FOO"]}).has_affiliation_of_type?(:affiliate).should be_true
  end
  
  it "should return addresses" do
    address_bind()
    Person.find_by_uid('61065').addresses.first.should be_instance_of(Address)
    UCB::LDAP.clear_authentication
  end
  
  it "should return job appointments" do
    job_appointment_bind()
    Person.find_by_uid('61065').job_appointments.first.should be_instance_of(JobAppointment)
    UCB::LDAP.clear_authentication
  end
  
  it "should return namespaces" do
    namespace_bind()
    Person.find_by_uid('61065').namespaces.first.class.should  == Namespace
    UCB::LDAP.clear_authentication
  end
end


describe "Employee" do
  it "should return employee_staff?" do
    Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-TYPE-STAFF"]).should be_employee_staff
    Person.new({}).should_not be_employee_staff
  end
  
  it "should return employee_academic?" do
    Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-TYPE-ACADEMIC"]).should be_employee_academic
    Person.new({}).should_not be_employee_academic
  end
  
  it "should return employee_expired?" do
    Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-STATUS-EXPIRED"]).should be_employee_expired
    Person.new({}).should_not be_employee_expired
  end
  
  it "should return employee?" do
    Person.new({}).should_not be_employee
    Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-TYPE-STAFF"]).should be_employee
    Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-TYPE-ACADEMIC"]).should be_employee
    Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-TYPE-STAFF", "EMPLOYEE-STATUS-EXPIRED"]).should_not be_employee
  end
  
  it "should return employee_expiration_date" do
    p = Person.new({:berkeleyEduEmpExpDate => '20000102080000Z'})
    p.employee_expiration_date.to_s.should == '2000-01-02'
  end
end


describe "Student" do
  it "should return student_registered?" do
    Person.new({}).should_not be_student_registered
    Person.new(:berkeleyEduAffiliations => ["STUDENT-TYPE-REGISTERED"]).should be_student_registered
  end
  
  it "should return student_not_registered?" do
    Person.new({}).should_not be_student_not_registered
    Person.new(:berkeleyEduAffiliations => ["STUDENT-TYPE-NOT REGISTERED"]).should be_student_not_registered
  end
  
  it "should return student_expired?" do
    Person.new({}).should_not be_student_expired
    Person.new(:berkeleyEduAffiliations => ["STUDENT-STATUS-EXPIRED"]).should be_student_expired
  end
  
  it "should return student?" do
    Person.new({}).should_not be_student
    Person.new(:berkeleyEduAffiliations => ["STUDENT-TYPE-FOO"]).should be_student
    Person.new(:berkeleyEduAffiliations => ["STUDENT-TYPE-FOO", "STUDENT-STATUS-EXPIRED"]).should_not be_student
  end
  
  it "should return student_expiration_date()" do
    student = Person.new(:berkeleyEduStuExpDate => '20070912080000Z')
    student.student_expiration_date.to_s.should == '2007-09-12'
  end
end


describe "Affiliate" do
  it "should return affiliate?" do
    Person.new({}).should_not be_affiliate
    Person.new(:berkeleyEduAffiliations => ["AFFILIATE-TYPE-FOO"]).should be_affiliate
    Person.new(:berkeleyEduAffiliations => ["AFFILIATE-TYPE-FOO", "AFFILIATE-STATUS-EXPIRED"]).should_not be_affiliate
  end
      
  it "should return affiliate_expiration_date()" do
    student = Person.new(:berkeleyEduAffExpDate => '20070912080000Z')
    student.affiliate_expiration_date.to_s.should == '2007-09-12'
  end
  
  it "should return affiliate_expired?" do
    Person.new({}).should_not be_affiliate_expired
    Person.new(:berkeleyEduAffiliations => ["AFFILIATE-STATUS-EXPIRED"]).should be_affiliate_expired
  end
end

