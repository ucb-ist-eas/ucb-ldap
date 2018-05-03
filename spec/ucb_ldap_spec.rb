require_relative "spec_helper"


describe "UCB::LDAP" do
  before(:all) do
    UCB::LDAP.clear_instance_variables
  end

  after(:all) do
    UCB::LDAP.clear_instance_variables
  end

  it "should allow host to be reset" do
    UCB::LDAP.host = 'foo'
    expect(UCB::LDAP.host).to eq('foo')
  end

  it "should raise BindFailedException given bad host name" do
    UCB::LDAP.host = 'bogus'
    expect(lambda { UCB::LDAP.new_net_ldap }).to raise_error(BindFailedException)
  end
end


describe "UCB::LDAP.new_net_ldap" do
  before(:all) do
    UCB::LDAP.clear_instance_variables
    @net_ldap = UCB::LDAP.new_net_ldap
  end

  after(:all) do
    UCB::LDAP.clear_instance_variables
  end

  it "should return Net:LDAP instance" do
    expect(@net_ldap).to be_instance_of(Net::LDAP)
  end

  it "should use host from UCB::LDAP.host" do
    @net_ldap = UCB::LDAP.new_net_ldap
    expect(@net_ldap.host).to equal(UCB::LDAP.host)
  end

  it "should use port 636" do
    expect(@net_ldap.port).to eq(636)
  end

  it "should use simple_tls encryption" do
    expect(@net_ldap.instance_variable_get(:@encryption)).to eq({method: :simple_tls, tls_options: {}})
  end

  it "should use anonymous authorization" do
    expect(@net_ldap.instance_variable_get(:@auth)).to eq({:method => :anonymous})
  end
end


describe "UCB::LDAP.net_ldap w/anonymous bind" do
  it "should return a cached Net::LDAP instance" do
    @net_ldap_1 = UCB::LDAP.net_ldap
    expect(@net_ldap_1).to be_instance_of(Net::LDAP)

    @net_ldap_2 = UCB::LDAP.net_ldap
    expect(@net_ldap_2).to eq(@net_ldap_1)
  end
end


describe "UCB::LDAP.authenticate" do
  before(:all) do
    UCB::LDAP.clear_instance_variables
  end

  after(:all) do
    UCB::LDAP.clear_instance_variables
  end

  it "should raise BindFailedException with bad username/password" do
    expect(lambda { UCB::LDAP.authenticate("bogus", "bogus") }).to raise_error(BindFailedException)
  end
end

describe UCB::LDAP, "date/datetime parsing" do
  before(:all) do
    @local_date_string = '20010203000000'
  end

  it "parsing returns nil given nil" do
    expect(UCB::LDAP.local_date_parse(nil)).to be_nil
    expect(UCB::LDAP.local_datetime_parse(nil)).to be_nil
  end

  it "local_date_parse should take local DateTime and return local Date" do
    expect(UCB::LDAP.local_date_parse('20010203000000').to_s).to eq('2001-02-03')
    expect(UCB::LDAP.local_date_parse('20010203235959').to_s).to eq('2001-02-03')
  end

  it "local_date_parse should take UTC DateTime and return local Date" do
    expect(UCB::LDAP.local_date_parse('20010203080000Z').to_s).to eq('2001-02-03')
    expect(UCB::LDAP.local_date_parse('20010203060000Z').to_s).to eq('2001-02-02')
  end

  it "local_datetime_parse should take local DateTime and return local Date" do
    expect(UCB::LDAP.local_datetime_parse('20010203000000').to_s).to eq('2001-02-03T00:00:00-08:00')
    expect(UCB::LDAP.local_datetime_parse('20010203235959').to_s).to eq('2001-02-03T23:59:59-08:00')
  end

  it "local_datetime_parse should take UTC DateTime and return local Date" do
    expect(UCB::LDAP.local_datetime_parse('20010203080000Z').to_s).to eq('2001-02-03T00:00:00-08:00')
    expect(UCB::LDAP.local_datetime_parse('20010203060000Z').to_s).to eq('2001-02-02T22:00:00-08:00')
  end
end
