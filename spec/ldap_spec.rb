require File.expand_path("#{File.dirname(__FILE__)}/_setup")


describe "UCB::LDAP" do
  before(:all) do
    UCB::LDAP.clear_instance_variables
  end
  
  after(:all) do
    UCB::LDAP.clear_instance_variables
    UCB::LDAP.host = HOST_TEST
  end
  
  it "should define host constants" do
    UCB::LDAP::HOST_PRODUCTION.should == 'ldap.berkeley.edu'      
    UCB::LDAP::HOST_TEST.should == 'ldap-test.berkeley.edu' 
  end
  
  it "should default host to production" do
    UCB::LDAP.host.should == UCB::LDAP::HOST_PRODUCTION
  end
  
  it "should allow host to be reset" do
    UCB::LDAP.host = 'foo'
    UCB::LDAP.host.should == 'foo'
  end
  
  it "should reconnect when host changes" do
    UCB::LDAP.host = HOST_PRODUCTION
    net_ldap1 = UCB::LDAP.net_ldap
    net_ldap1.should equal(UCB::LDAP.net_ldap)

    UCB::LDAP.host = HOST_TEST
    net_ldap1.should_not equal(UCB::LDAP.net_ldap)
  end

  it "should raise BindFailedException given bad host name" do
    UCB::LDAP.host = 'bogus'
    lambda { UCB::LDAP.new_net_ldap }.should raise_error(BindFailedException)
  end
  
  it "should reconnect after time-out"
#     UCB::LDAP.host = HOST_TEST
#     namespace_bind() # expires in 5 seconds
#     net_ldap1 = UCB::LDAP.net_ldap
#     net_ldap1.should equal(UCB::LDAP.net_ldap) # same instance right away
#     30.times{|i| print "#{i},";STDOUT.flush; sleep(1)}; puts  # force time-out
#     #UCB::LDAP.instance_variable_set(:@net_ldap, nil)
#     #net_ldap1.should_not equal(UCB::LDAP.net_ldap)
#     net_ldap1.bind
#   end  
end


describe "UCB::LDAP binding with rails" do
  before do
    UCB::LDAP.clear_instance_variables
  end
  
  after(:all) do
    UCB::LDAP.clear_instance_variables
    UCB::LDAP.host = HOST_TEST
  end
  
  it "bind_for_rails() should authenticate with environment-specific bind" do
    bind_file = "#{File.dirname(__FILE__)}/rails_binds.yml"
    UCB::LDAP.should_receive(:authenticate).with('username_development', 'password_development')
    UCB::LDAP.bind_for_rails(bind_file, 'development')
    
    lambda { UCB::LDAP.bind_for_rails(bind_file, 'bogus') }.should raise_error
  end
  
  it "bind_for_rails() should raise exception if bind file not found" do
    missing_file = "#{File.dirname(__FILE__)}/missing.yml"
    lambda { UCB::LDAP.bind_for_rails(missing_file, 'development') }.should raise_error  # no error raised
  end
end


describe "UCB::LDAP.new_net_ldap()" do
  before(:all) do
    UCB::LDAP.clear_instance_variables
    UCB::LDAP.host = HOST_TEST
    @net_ldap = UCB::LDAP.new_net_ldap
  end
  
  after(:all) do
    UCB::LDAP.clear_instance_variables
    UCB::LDAP.host = HOST_TEST
  end
  
  it "should return Net:LDAP instance" do
    @net_ldap.should be_instance_of(Net::LDAP)
  end
  
  it "should use host from UCB::LDAP.host" do
    @net_ldap.host.should == HOST_TEST
    
    @net_ldap = UCB::LDAP.new_net_ldap
    @net_ldap.host.should equal(UCB::LDAP.host)
  end
  
  it "should use port 636" do
    @net_ldap.port.should == 636
  end
  
  it "should use simple_tls encryption" do
    @net_ldap.instance_variable_get(:@encryption).should == {:method => :simple_tls}  
  end
  
  it "should use anonymous authorization" do
    @net_ldap.instance_variable_get(:@auth).should == {:method => :anonymous}
  end
end


describe "UCB::LDAP.net_ldap() w/anonymous bind" do
  it "should return a cached Net::LDAP instance" do
    @net_ldap_1 = UCB::LDAP.net_ldap
    @net_ldap_1.should be_instance_of(Net::LDAP)
    
    @net_ldap_2 = UCB::LDAP.net_ldap
    @net_ldap_2.should equal(@net_ldap_1)
  end
end


describe "UCB::LDAP.authenticate()" do
  before(:all) do
    UCB::LDAP.clear_instance_variables
    UCB::LDAP.host = HOST_TEST
  end
  
  after(:all) do
    UCB::LDAP.clear_instance_variables
    UCB::LDAP.host = HOST_TEST
  end

  it "should raise BindFailedException with bad username/password" do
    lambda { UCB::LDAP.authenticate("bogus", "bogus") }.should raise_error(BindFailedException)
  end
  
  it "should create new Net::LDAP instance" do
    net_ldap = UCB::LDAP.net_ldap
    org_bind()
    UCB::LDAP.net_ldap.should_not equal(net_ldap)
  end
end


describe "UCB::LDAP.clear_authentication()" do
  it "should remove authentication and revert to anonymous bind" do
    org_bind()
    net_ldap1 = UCB::LDAP.net_ldap 
    net_ldap1.instance_variable_get(:@auth)[:method].should == :simple

    UCB::LDAP.clear_authentication
    UCB::LDAP.net_ldap.instance_variable_get(:@auth)[:method].should == :anonymous
    net_ldap1.should_not equal(UCB::LDAP.net_ldap)
  end
end


describe UCB::LDAP, "date/datetime parsing" do
  before(:all) do
    @local_date_string = '20010203000000'
  end
  
  it "parsing returns nil given nil" do
    UCB::LDAP.local_date_parse(nil).should be_nil
    UCB::LDAP.local_datetime_parse(nil).should be_nil
  end
  
  it "local_date_parse should take local DateTime and return local Date" do
    UCB::LDAP.local_date_parse('20010203000000').to_s.should == '2001-02-03'
    UCB::LDAP.local_date_parse('20010203235959').to_s.should == '2001-02-03'
  end

  it "local_date_parse should take UTC DateTime and return local Date" do
    UCB::LDAP.local_date_parse('20010203080000Z').to_s.should == '2001-02-03'
    UCB::LDAP.local_date_parse('20010203060000Z').to_s.should == '2001-02-02'
  end

  it "local_datetime_parse should take local DateTime and return local Date" do
    UCB::LDAP.local_datetime_parse('20010203000000').to_s.should == '2001-02-03T00:00:00-08:00'
    UCB::LDAP.local_datetime_parse('20010203235959').to_s.should == '2001-02-03T23:59:59-08:00'
  end

  it "local_datetime_parse should take UTC DateTime and return local Date" do
    UCB::LDAP.local_datetime_parse('20010203080000Z').to_s.should == '2001-02-03T00:00:00-08:00'
    UCB::LDAP.local_datetime_parse('20010203060000Z').to_s.should == '2001-02-02T22:00:00-08:00'
  end
end
