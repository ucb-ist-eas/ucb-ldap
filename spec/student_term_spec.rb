require File.expand_path("#{File.dirname(__FILE__)}/_setup")

describe "UCB::LDAP::StudentTerm" do
  before(:all) do
    job_appointment_bind() # in _setup_specs.rb
    @student_uid = "191501"
    @student = Person.find_by_uid(@student_uid)
    @datetime_string = '20010203040506Z'
    @date_expected = '2001-02-03'
    @datetime_expected = '2001-02-02T20:05:06-08:00'
  end

  before(:each) do
  end
  
  after(:all) do
    UCB::LDAP.clear_authentication
  end

  it "find_by_uid() should return terms" do
    StudentTerm.find_by_uid(@student_uid).class.should == Array
  end
  
  it "should be able to get terms from UCB::LDAP::Person instance" do
    @student.student_terms.class.should == Array
  end
  
  it "should return change_datetime()" do
    StudentTerm.new({}).change_datetime.should be_nil
    StudentTerm.new({:berkeleyEduStuChangeDate => [@datetime_string]}).change_datetime.to_s.should == @datetime_expected
  end
  
  it "should return college_code()" do
    StudentTerm.new({}).college_code.should be_nil
    StudentTerm.new({:berkeleyEduStuCollegeCode => ['foo']}).college_code.should == 'foo'
  end
    
  it "should return college_name()" do
    StudentTerm.new({}).college_name.should be_nil
    StudentTerm.new({:berkeleyEduStuCollegeName => ['foo']}).college_name.should == 'foo'
  end

  it "should return level_code()" do
    StudentTerm.new({}).level_code.should be_nil
    StudentTerm.new({:berkeleyEduStuEduLevelCode => ['foo']}).level_code.should == 'foo'
  end

  
  it "should return level_name()" do
    StudentTerm.new({}).level_name.should be_nil
    StudentTerm.new({:berkeleyEduStuEduLevelName => ['foo']}).level_name.should == 'foo'
  end

  
  it "should return role_code()" do
    StudentTerm.new({}).role_code.should be_nil
    StudentTerm.new({:berkeleyEduStuEduRoleCode => ['foo']}).role_code.should == 'foo'
  end

  
  it "should return role_name()" do
    StudentTerm.new({}).role_name.should be_nil
    StudentTerm.new({:berkeleyEduStuEduRoleName => ['foo']}).role_name.should == 'foo'
  end

  
  it "should return major_code()" do
    StudentTerm.new({}).major_code.should be_nil
    StudentTerm.new({:berkeleyEduStuMajorCode => ['foo']}).major_code.should == 'foo'
  end

  
  it "should return major_name()" do
    StudentTerm.new({}).major_name.should be_nil
    StudentTerm.new({:berkeleyEduStuMajorName => ['foo']}).major_name.should == 'foo'
  end

  
  it "should return registration_status_code()" do
    StudentTerm.new({}).registration_status_code.should be_nil
    StudentTerm.new({:berkeleyEduStuRegStatCode => ['foo']}).registration_status_code.should == 'foo'
  end

  
  it "should return registration_status_name()" do
    StudentTerm.new({}).registration_status_name.should be_nil
    StudentTerm.new({:berkeleyEduStuRegStatName => ['foo']}).registration_status_name.should == 'foo'
  end

  
  it "should return term_code()" do
    StudentTerm.new({}).term_code.should be_nil
    StudentTerm.new({:berkeleyEduStuTermCode => ['foo']}).term_code.should == 'foo'
  end

  
  it "should return term_name()" do
    StudentTerm.new({}).term_name.should be_nil
    StudentTerm.new({:berkeleyEduStuTermName => ['foo']}).term_name.should == 'foo'
  end

  
  it "should return term_status()" do
    StudentTerm.new({}).term_status.should be_nil
    StudentTerm.new({:berkeleyEduStuTermStatus => ['foo']}).term_status.should == 'foo'
  end

  
  it "should return term_year()" do
    StudentTerm.new({}).term_year.should be_nil
    StudentTerm.new({:berkeleyEduStuTermYear => ['2000']}).term_year.should == 2000
  end

  
  it "should return under_graduate_code()" do
    StudentTerm.new({}).under_graduate_code.should be_nil
    StudentTerm.new({:berkeleyEduStuUGCode => ['foo']}).under_graduate_code.should == 'foo'
  end

end

