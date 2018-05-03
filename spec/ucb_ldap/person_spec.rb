require_relative "../spec_helper"


describe UCB::LDAP::Person, "searching for test entries" do
  it "excludes test entries by default" do
    Person.instance_variable_set(:@include_test_entries, nil)
    expect(Person.include_test_entries?).to be false
    expect(Person.find_by_uid("212387")).to be_nil
  end

  it "allows for test entries to be included" do
    Person.include_test_entries = true
    expect(Person.include_test_entries?).to be true
    expect(Person.find_by_uid("212387").uid).to eq("212387")
  end
end


describe UCB::LDAP::Person do
  before(:all) do
    @staff = Person.find_by_uid "212387"
    @student = Person.find_by_uid "232588"
  end

  it "constructor should return Person instances" do
    expect(@staff).to be_instance_of(Person)
    expect(@student).to be_instance_of(Person)
  end

  it "persons_by_uid should return Array of Person" do
    persons = Person.find_by_uids ['212386', '212387']
    expect(persons).to be_instance_of(Array)
    expect(persons.count).to eq(2)
    expect(persons[0]).to be_instance_of(Person)
    expect(persons[0].uid).to eq('212386')
    expect(persons[1].uid).to eq('212387')

    expect(Person.persons_by_uids([])).to eq([])
  end

  it "find_by_uid(s) is an alias for person(s)_by_uid" do
    expect(Person.respond_to?(:find_by_uids)).to be true
    expect(Person.respond_to?(:find_by_uid)).to be true
  end

  it "find_by_uid works with a String or an Integer" do
    staff_from_int_uid = Person.find_by_uid(212387)
    expect(staff_from_int_uid.uid).to eq(@staff.uid)
  end
end


describe "UCB::LDAP::Person instance" do
  before(:all) do
    @staff = Person.find_by_uid("212387")
    @student = Person.find_by_uid("232588")
    @staff_with_org = Person.find_by_uid("5999")
  end

  it "should know if an person is a test entry" do
    expect(@staff.test?).to be true
    expect(Person.find_by_uid('212387').test?).to be true
  end

  it "should return uid as scalar" do
    expect(@staff.uid).to eq("212387")
  end

  it "should return firstname and first_name as (scalar) synonyms for givenname" do
    expect(@staff.givenname).to eq(['EMP-STAFF'])
    expect(@staff.firstname).to eq('EMP-STAFF')
    expect(@staff.first_name).to eq('EMP-STAFF')
  end

  it "should return lastname and last_name as (scalar) synonyms for sn" do
    expect(@staff.sn).to eq(['TEST'])
    expect(@staff.lastname).to eq('TEST')
    expect(@staff.last_name).to eq('TEST')
  end

  it "should return email as scalar synonym for mail" do
    expect(@staff.mail).to eq(%w(test-212387@berkeley.edu))
    expect(@staff.email).to eq('test-212387@berkeley.edu')
  end

  it "should return phone as scalar synonym for telephoneNumber" do
    expect(@staff.telephoneNumber).to eq(['+1 (510) 643-1234'])
    expect(@staff.phone).to eq('+1 (510) 643-1234')
  end

  it "should return deptid, dept_code as scalar synonym for berkeleyEduPrimaryDeptUnit" do
    expect(@staff_with_org.departmentNumber).to eq(['JKASD'])
    expect(@staff_with_org.deptid).to eq('JKASD')
    expect(@staff_with_org.dept_code).to eq('JKASD')
  end

  it "should return org_node (UCB::LDAP::Org instance)" do
    expect(@staff_with_org.org_node).to be_instance_of(Org)
    expect(@staff_with_org.org_node.deptid).to eq('JKASD')
  end

  it "should return affiliations" do
    expect(@staff.affiliations).to include('EMPLOYEE-TYPE-STAFF')
    expect(@student.affiliations).to include('STUDENT-TYPE-REGISTERED')

    expect(@staff.has_affiliation?("bogus")).to be false
    expect(@staff.has_affiliation?('EMPLOYEE-TYPE-STAFF')).to be true
    expect(@staff.has_affiliation?('employee-type-staff')).to be true

    expect(@student.has_affiliation?("bogus")).to be false
    expect(@student.has_affiliation?('STUDENT-TYPE-REGISTERED')).to be true
    expect(@student.has_affiliation?('student-type-registered')).to be true
  end

  it "should return has_affiliation_of_type?()" do
    expect(Person.new({}).has_affiliation_of_type?(:affiliate)).to be false
    expect(Person.new({:berkeleyEduAffiliations => ["AFFILIATE-TYPE-FOO"]}).has_affiliation_of_type?(:affiliate)).to be true
  end

end

describe "Employee" do
  it "should return employee_staff?" do
    expect(Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-TYPE-STAFF"])).to be_employee_staff
    expect(Person.new({})).not_to be_employee_staff
  end

  it "should return employee_academic?" do
    expect(Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-TYPE-ACADEMIC"])).to be_employee_academic
    expect(Person.new({})).not_to be_employee_academic
  end

  it "should return employee_expired?" do
    expect(Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-STATUS-EXPIRED"])).to be_employee_expired
    expect(Person.new({})).not_to be_employee_expired
  end

  it "should return employee?" do
    expect(Person.new({})).not_to be_employee
    expect(Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-TYPE-STAFF"])).to be_employee
    expect(Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-TYPE-ACADEMIC"])).to be_employee
    expect(Person.new(:berkeleyEduAffiliations => ["EMPLOYEE-TYPE-STAFF", "EMPLOYEE-STATUS-EXPIRED"])).not_to be_employee
  end
end


describe "Student" do
  it "should return student_registered?" do
    expect(Person.new({})).not_to be_student_registered
    expect(Person.new(:berkeleyEduAffiliations => ["STUDENT-TYPE-REGISTERED"])).to be_student_registered
  end

  it "should return student_not_registered?" do
    expect(Person.new({})).not_to be_student_not_registered
    expect(Person.new(:berkeleyEduAffiliations => ["STUDENT-TYPE-NOT REGISTERED"])).to be_student_not_registered
  end

  it "should return student_expired?" do
    expect(Person.new({})).not_to be_student_expired
    expect(Person.new(:berkeleyEduAffiliations => ["STUDENT-STATUS-EXPIRED"])).to be_student_expired
  end

  it "should return student?" do
    expect(Person.new({})).not_to be_student
    expect(Person.new(:berkeleyEduAffiliations => ["STUDENT-TYPE-FOO"])).to be_student
    expect(Person.new(:berkeleyEduAffiliations => ["STUDENT-TYPE-FOO", "STUDENT-STATUS-EXPIRED"])).not_to be_student
  end
end


describe "Affiliate" do
  it "should return affiliate?" do
    expect(Person.new({})).not_to be_affiliate
    expect(Person.new(:berkeleyEduAffiliations => ["AFFILIATE-TYPE-FOO"])).to be_affiliate
    expect(Person.new(:berkeleyEduAffiliations => ["AFFILIATE-TYPE-FOO", "AFFILIATE-STATUS-EXPIRED"])).not_to be_affiliate
  end

  it "should return affiliate_expired?" do
    expect(Person.new({})).not_to be_affiliate_expired
    expect(Person.new(:berkeleyEduAffiliations => ["AFFILIATE-STATUS-EXPIRED"])).to be_affiliate_expired
  end
end

