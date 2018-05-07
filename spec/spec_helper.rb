require 'rubygems'
require 'rspec'
require_relative "../lib/ucb_ldap"

# TODO: we should get rid of this if possible
$TESTING = true

include UCB::LDAP

def load_config_file
  config_file = "#{File.dirname(__FILE__)}/ldap_config.yml"
  return nil unless File.exists?(config_file)
  YAML.load(IO.read(config_file))["ldap"]
end

def exit_with_missing_config
  puts <<-END_MESSAGE.gsub(/^ {4}/, '')

    **************** Unable to find spec/ldap_config.yml file ****************

    Specs cannot run without the correct LDAP credentials. To set this up, run:

        cp spec/ldap_config.yml.example spec/ldap_config.yml

    Then populate the file with the correct username and password. You can get
    these from another developer on the team.

  END_MESSAGE
  exit -1
end

def init_with_config(config)
  UCB::LDAP.host = config["host"]
  UCB::LDAP.authenticate(config["username"], config["password"])
  UCB::LDAP::Person.include_test_entries = config["include_test_entries"]
end


RSpec.configure do |config|
  # config block
  if UCB::LDAP.username.nil?
    config = load_config_file or exit_with_missing_config
    init_with_config(config)
  end
end

