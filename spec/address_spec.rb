require File.expand_path("#{File.dirname(__FILE__)}/_setup")

describe "UCB::LDAP::Address" do
  before(:all) do
    address_bind()
  end

  before(:each) do
    # assumes 'sh' has 1 address, 'ba' has 1
    @sh_addresses = Address.find_by_uid('61065')
    @ba_addresses = Address.find_by_uid('230455')
  end
  
  after(:all) do
    UCB::LDAP.clear_authentication
  end
  
  it "should find addresses by uid" do
    @sh_addresses.should be_instance_of(Array)
    @sh_addresses.first.should be_instance_of(Address)
    @sh_addresses.size.should == 1
    
    @ba_addresses.size.should == 1
  end

  it "should know primary work address" do
    @sh_addresses.first.should be_primary_work_address
    
    @ba_addresses.each do |addr|
      addr.should(be_primary_work_address) if addr.berkeleyEduPersonAddressPrimaryFlag
      addr.should_not(be_primary_work_address) if !addr.berkeleyEduPersonAddressPrimaryFlag
    end
  end
  
  it "should return addresses in sort order" do
    [@sh_addresses, @ba_addresses].each do |addresses|
      addresses.each_with_index do |addr, i|
        addr.sort_order.should == (i + 1)
      end
    end
  end

#  it "should print itself" do
#    [@sh_addresses, @ba_addresses].flatten.each do |a|
#      puts "----"
#      a.attributes.keys.sort_by{|k|k.to_s}.each do |k|
#        puts "#{k}: #{a.attributes[k].inspect}"#, a.send(k).inspect
#      end
#    end
#  end
  
end

