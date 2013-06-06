$TESTING = true
$:.unshift(File.dirname(__FILE__) + '/../lib')
# $:.unshift("/Users/glie/Development/workspace/ruby_gems_projects/ruby-net-ldap/lib")
# $:.unshift("/usr/local/lib/ruby/gems/1.8/gems/ruby-net-ldap-0.0.4/lib")

require 'spec'
require 'ucb_ldap'
require 'pp'

include UCB::LDAP
# UCB::LDAP.host = UCB::LDAP::HOST_TEST
HOST_TEST = "ds-t1.calnet.1918.berkeley.edu"
UCB::LDAP.host = HOST_TEST

 
$binds ||= YAML.load(IO.read("#{File.dirname(__FILE__)}/binds.yml"))

def bind_for(bind_key)
  bind = $binds[bind_key] or raise("No bind found for '#{bind_key}'")
  UCB::LDAP.authenticate(bind["username"], bind["password"])
end

def address_bind
  bind_for("address")
end

def job_appointment_bind
  bind_for("job_appointment")
end

def namespace_bind
  bind_for("namespace")
end

def org_bind
  bind_for("org")
end

def affiliation_bind
  bind_for("affiliation")
end

def service_bind
  bind_for("affiliation")
end
